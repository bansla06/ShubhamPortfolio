"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Nav() {
  const pathname = usePathname();
  return (
    <nav className="nav">
      <div className="wrap nav__inner">
        <Link href="/" className="nav__brand">
          <span className="dot"></span>
          Shubham Bansla
          <small>Product analyst</small>
        </Link>
        <div className="nav__links">
          <Link href="/about" className={pathname === "/about" ? "is-active" : ""}>About</Link>
          <Link href="/academics" className={pathname === "/academics" ? "is-active" : ""}>Academics</Link>
          <Link href="/experience" className={pathname === "/experience" ? "is-active" : ""}>Experience</Link>
          <Link href="/work" className={pathname === "/work" ? "is-active" : ""}>Work</Link>
          <Link href="/achievements" className={pathname === "/achievements" ? "is-active" : ""}>Achievements</Link>
        </div>
        <Link href="/contact" className="nav__cta">Get in touch</Link>
      </div>
    </nav>
  );
}
