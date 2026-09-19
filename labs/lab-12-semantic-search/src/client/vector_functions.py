"""
Vector search functions for storing and retrieving documents with embeddings from Cosmos DB.
These functions serve as the interface between the Flask app and Cosmos DB vector search.
"""
import os
from datetime import datetime
from azure.cosmos import CosmosClient, exceptions
from azure.identity import DefaultAzureCredential


def get_container():
    """Get a reference to the Cosmos DB container."""
    endpoint = os.environ.get("COSMOS_ENDPOINT")
    database_name = os.environ.get("COSMOS_DATABASE")
    container_name = os.environ.get("COSMOS_CONTAINER")
    key = os.environ.get("COSMOS_KEY") # Allow Key auth

    if not endpoint or not database_name or not container_name:
        raise ValueError(
            "COSMOS_ENDPOINT, COSMOS_DATABASE, and COSMOS_CONTAINER "
            "environment variables must be set"
        )

    if key:
        client = CosmosClient(endpoint, credential=key)
    else:
        credential = DefaultAzureCredential()
        client = CosmosClient(endpoint, credential=credential)
        
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    return container


# BEGIN STORE VECTOR DOCUMENT FUNCTION
def store_vector_document(
    document_id: str, chunk_id: str, content: str, embedding: list, metadata: dict = None
) -> dict:
    """Store a document with its vector embedding for similarity search."""
    container = get_container()
    
    document = {
        "id": chunk_id,
        "documentId": document_id,
        "content": content,
        "embedding": embedding,  # 256-dimensional vector for similarity search
        "metadata": metadata or {},
        "createdAt": datetime.utcnow().isoformat(),
        "chunkIndex": metadata.get("chunkIndex", 0) if metadata else 0
    }
    
    # upsert_item inserts if new, updates if exists (based on id + partition key)
    response = container.upsert_item(body=document)
    ru_charge = response.get_response_headers().get('x-ms-request-charge', 0)
    
    return {
        "chunk_id": chunk_id,
        "document_id": document_id,
        "ru_charge": float(ru_charge)
    }
# END STORE VECTOR DOCUMENT FUNCTION


# BEGIN VECTOR SIMILARITY SEARCH FUNCTION
def vector_similarity_search(
    query_embedding: list, top_n: int = 5
) -> list:
    """Find documents most similar to the query using vector distance."""
    container = get_container()
    
    # The VectorDistance function calculates cosine similarity
    query = """
        SELECT TOP @topN c.id, c.documentId, c.content, c.metadata, 
        VectorDistance(c.embedding, @queryVector) AS similarityScore
        FROM c
        ORDER BY VectorDistance(c.embedding, @queryVector)
    """
    
    items = container.query_items(
        query=query,
        parameters=[
            {"name": "@topN", "value": top_n},
            {"name": "@queryVector", "value": query_embedding}
        ],
        enable_cross_partition_query=True
    )
    
    return [
        {
            "chunk_id": item["id"],
            "document_id": item["documentId"],
            "content": item["content"],
            "metadata": item["metadata"],
            "similarity_score": item["similarityScore"]
        }
        for item in items
    ]
# END VECTOR SIMILARITY SEARCH FUNCTION


# BEGIN FILTERED VECTOR SEARCH FUNCTION
def filtered_vector_search(query_embedding: list, category: str = None, top_k: int = 3) -> list:
    """Perform a vector similarity search with metadata filtering."""
    container = get_container()
    
    if category:
        query = """
        SELECT TOP @top_k c.id, c.documentId, c.content, c.metadata, 
               VectorDistance(c.embedding, @query_embedding) AS similarityScore
        FROM c
        WHERE c.metadata.category = @category
        ORDER BY VectorDistance(c.embedding, @query_embedding)
        """
        parameters = [
            {"name": "@top_k", "value": top_k},
            {"name": "@query_embedding", "value": query_embedding},
            {"name": "@category", "value": category}
        ]
    else:
        query = """
        SELECT TOP @top_k c.id, c.documentId, c.content, c.metadata, 
               VectorDistance(c.embedding, @query_embedding) AS similarityScore
        FROM c
        ORDER BY VectorDistance(c.embedding, @query_embedding)
        """
        parameters = [
            {"name": "@top_k", "value": top_k},
            {"name": "@query_embedding", "value": query_embedding}
        ]
        
    items = container.query_items(
        query=query,
        parameters=parameters,
        enable_cross_partition_query=True
    )
    
    results = []
    for item in items:
        results.append({
            "id": item.get("id"),
            "document_id": item.get("documentId"),
            "content": item.get("content"),
            "metadata": item.get("metadata", {}),
            "similarity_score": item.get("similarityScore")
        })
        
    return results
# END FILTERED VECTOR SEARCH FUNCTION


def get_all_categories() -> list:
    """Get a list of unique categories from the container."""
    try:
        container = get_container()
        query = "SELECT DISTINCT c.metadata.category FROM c WHERE IS_DEFINED(c.metadata.category)"
        items = container.query_items(
            query=query,
            enable_cross_partition_query=True
        )
        return sorted([item["category"] for item in items if item.get("category")])
    except Exception:
        return []


def get_all_document_ids() -> list:
    """Get a list of unique document IDs from the container."""
    try:
        container = get_container()
        query = "SELECT DISTINCT c.documentId FROM c"
        items = container.query_items(
            query=query,
            enable_cross_partition_query=True
        )
        return sorted([item["documentId"] for item in items])
    except Exception:
        return []
