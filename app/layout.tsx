import { RootProvider } from 'fumadocs-ui/provider/next';
import './global.css';
import { Libre_Franklin, Fraunces } from 'next/font/google';

const libreFranklin = Libre_Franklin({
  subsets: ['latin'],
  variable: '--font-body',
});

const fraunces = Fraunces({
  subsets: ['latin'],
  variable: '--font-heading',
});

export default function Layout({ children }: LayoutProps<'/'>) {
  return (
    <html lang="en" className={`${libreFranklin.variable} ${fraunces.variable} font-sans`} suppressHydrationWarning>
      <body className="flex flex-col min-h-screen">
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}
