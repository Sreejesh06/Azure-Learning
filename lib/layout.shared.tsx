import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';
import { appName, gitConfig } from './shared';
import Image from 'next/image';

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      // JSX supported
      title: (
        <div className="flex items-center gap-3">
          <Image 
            src="/images/logo.png" 
            alt="Azure AI Hub Logo" 
            width={72} 
            height={72} 
            className="dark:invert drop-shadow-sm -my-2"
          />
          <span className="font-serif font-bold text-2xl tracking-tight mt-1">{appName}</span>
        </div>
      ),
    },
    githubUrl: `https://github.com/${gitConfig.user}/${gitConfig.repo}`,
  };
}
