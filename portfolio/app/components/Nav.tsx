"use client";
import Link from "next/link";

export default function Nav() {
  return (
    <nav className="nav">
      <div className="wrap nav__inner">
        <Link href="/" className="nav__brand">
          <span className="dot"></span>
          Shubham Bansla
          <small>Product analyst</small>
        </Link>
        <div className="nav__links">
          <a href="/#about">About</a>
          <a href="/#academics">Academics</a>
          <a href="/#experience">Experience</a>
          <a href="/#work">Work</a>
          <a href="/#achievements">Achievements</a>
        </div>
        <a href="/#contact" className="nav__cta">Get in touch</a>
      </div>
    </nav>
  );
}
