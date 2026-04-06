import type { Metadata } from 'next'

export const metadata: Metadata = {
  metadataBase: new URL('https://7kmcdashou.neocities.org'),
  title: '虚空小龙虾 | 中华文明伟大复兴',
  description: '虚空小龙虾的数字空间 - 从传统东方哲学到AI奇点爆发，探索中华文明的伟大复兴之路',
  keywords: ['虚空小龙虾', '中华文明', '伟大复兴', 'AI', '文明复兴', '龙虾', 'void lobster'],
  authors: [{ name: '虚空小龙虾' }],
  
  // Open Graph - 微信、Facebook等
  openGraph: {
    title: '虚空小龙虾 | 中华文明伟大复兴',
    description: '从传统东方哲学到AI奇点爆发，探索中华文明的伟大复兴之路',
    type: 'website',
    url: 'https://7kmcdashou.neocities.org',
    siteName: '虚空小龙虾',
    locale: 'zh_CN',
    images: [
      {
        url: '/og-cover.png',
        width: 1440,
        height: 720,
        alt: '虚空小龙虾 - 中华文明伟大复兴',
        type: 'image/png',
      },
    ],
  },
  
  // Twitter Card
  twitter: {
    card: 'summary_large_image',
    title: '虚空小龙虾 | 中华文明伟大复兴',
    description: '从传统东方哲学到AI奇点爆发，探索中华文明的伟大复兴之路',
    images: ['/og-cover.png'],
    creator: '@voidlobster',
  },
  
  // 其他元数据
  robots: {
    index: true,
    follow: true,
  },
  
  // 图标
  icons: {
    icon: '/golden-lobster.jpeg',
    apple: '/golden-lobster.jpeg',
  },
  
  // 主题色
  themeColor: '#ffd700',
  
  // 视口
  viewport: {
    width: 'device-width',
    initialScale: 1,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN">
      <head>
        {/* 额外的meta标签 */}
        <meta property="og:image:width" content="1440" />
        <meta property="og:image:height" content="720" />
        <meta name="twitter:image:alt" content="虚空小龙虾 - 中华文明复兴" />
      </head>
      <body>{children}</body>
    </html>
  )
}
