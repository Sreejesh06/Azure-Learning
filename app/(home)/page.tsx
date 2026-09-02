import Link from 'next/link';
import Image from 'next/image';
import { ArrowRight, ExternalLink } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background text-foreground overflow-hidden">
      <main className="flex w-full max-w-5xl flex-col items-start px-6 py-12 md:py-24">

        {/* Proper 2-Column Hero Grid */}
        <div className="grid w-full grid-cols-1 md:grid-cols-2 gap-12 items-center">

          {/* Left Column: Text Content */}
          <div className="flex flex-col items-start z-10">
            {/* Badge */}


            {/* Main Heading */}
            <h1 className="font-serif text-[36px] font-semibold tracking-[-0.02em] md:text-[48px] max-w-[500px] animate-fade-in-up">
              Azure AI Cloud Developer Hub
            </h1>

            {/* Subtitle */}
            <p className="mt-4 max-w-[500px] text-[16px] leading-[26px] text-muted-foreground animate-fade-in-up delay-100">
              Master cloud-native AI systems on Microsoft Azure. Dive into Identity, Vector Search, Container Apps, and Event-Driven Pipelines. Built with strict engineering rigor.
            </p>

            {/* CTA Buttons */}
            <div className="mt-8 flex flex-col gap-4 sm:flex-row sm:items-center w-full animate-fade-in-up delay-200">
              <Link
                href="/docs"
                className="group inline-flex items-center justify-center gap-2 rounded-md bg-foreground px-6 py-3 text-[14px] font-medium text-background transition-colors hover:bg-foreground/90 w-full sm:w-auto"
              >
                Start Learning
                <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
              </Link>

              <Link
                href="https://learn.microsoft.com/en-gb/training/paths/implement-container-app-hosting-azure/"
                target="_blank"
                className="inline-flex items-center justify-center gap-2 rounded-md border border-border bg-background px-6 py-3 text-[14px] font-medium text-foreground transition-colors hover:bg-muted w-full sm:w-auto"
              >
                Official Exam Guide
                <ExternalLink className="h-4 w-4" />
              </Link>
            </div>
          </div>

          {/* Right Column: Premium Hero Focal Point */}
          <div className="relative flex items-center justify-center h-[350px] w-full hidden md:flex">
            {/* The single, un-cluttered anchor asset */}
            <div className="z-10 transition-transform duration-500 hover:scale-105 cursor-default animate-fade-in delay-300">
              <Image src="/images/icon_computer.png" alt="Pixel Computer" width={260} height={260} className="drop-shadow-2xl" />
            </div>
          </div>
        </div>

        <hr className="my-16 w-full border-border" />

        {/* Feature Grid (Meaningful Architecture without Overlaps) */}
        <div className="grid w-full grid-cols-1 gap-6 md:grid-cols-3 animate-fade-in-up delay-300">
          {[
            {
              title: 'Zero-Trust Security',
              desc: 'Learn Entra ID, Managed Identities, and passwordless models.',
              iconAsset: '/images/icon_folder.png',
            },
            {
              title: 'Vector Search & RAG',
              desc: 'Implement hybrid search pipelines using Azure AI Search.',
              iconAsset: '/images/icon_magnify.png',
            },
            {
              title: 'Cloud-Native Compute',
              desc: 'Deploy FastAPI microservices to Azure Container Apps.',
              iconAsset: '/images/icon_lightbulb.png',
            },
          ].map((feature, i) => (
            <div
              key={i}
              className="group flex flex-col items-start overflow-hidden rounded-xl border border-border bg-card p-6 text-card-foreground transition-all hover:bg-muted/30 hover:border-foreground/20 hover:shadow-sm"
            >
              {/* Visual Header Box: Clean, functional iconography */}
              <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-lg bg-muted/40 border border-border/50">
                <Image src={feature.iconAsset} alt={feature.title} width={40} height={40} className="drop-shadow-sm transition-transform duration-300 ease-out group-hover:scale-125 group-hover:rotate-6" />
              </div>

              <h3 className="text-[16px] font-semibold tracking-[-0.01em]">
                {feature.title}
              </h3>

              <p className="mt-2 text-[14px] leading-[22px] text-muted-foreground">
                {feature.desc}
              </p>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
