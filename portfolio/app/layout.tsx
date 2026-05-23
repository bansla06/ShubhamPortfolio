import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Shubham Bansla — Product Analyst",
  description: "Six years of finding the signal inside the noise. Product analytics across e-commerce, adtech, gaming and fintech.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
