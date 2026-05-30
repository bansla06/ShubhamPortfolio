"use client";
import Link from "next/link";
import Nav from "../components/Nav";
import Footer from "../components/Footer";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function Work() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <header className="page-head">
        <div className="wrap page-head__inner reveal">
          <div>
            <div className="crumb"><span />04 · Selected work</div>
            <h1>A few projects,<br /><em>told properly.</em></h1>
          </div>
          <p className="lede">
            I&apos;d rather walk you through three pieces of work end-to-end than flash
            twenty thumbnails. Click any tile for the case study.
          </p>
        </div>
      </header>

      <main className="page-body">
        <div className="wrap">
          <div className="projects reveal-stagger">
            <Link className="proj is-feat" href="/case/relevancy">
              <div className="proj__cover">
                <span className="label">Case study · Tira</span>
                <span className="year">2024</span>
                <svg className="cover-svg" viewBox="0 0 800 360" preserveAspectRatio="none">
                  <defs>
                    <linearGradient id="g1" x1="0" y1="0" x2="1" y2="1">
                      <stop offset="0" stopColor="#161A24" />
                      <stop offset="1" stopColor="#0E1118" />
                    </linearGradient>
                  </defs>
                  <rect width="800" height="360" fill="url(#g1)" />
                  <g stroke="#E0B973" strokeWidth="1.2" fill="none" opacity="0.5">
                    <rect x="40" y="180" width="120" height="150" />
                    <rect x="180" y="180" width="120" height="150" />
                    <rect x="320" y="180" width="120" height="150" fill="#E0B973" stroke="#E0B973" />
                    <rect x="460" y="180" width="120" height="150" />
                    <rect x="600" y="180" width="120" height="150" />
                  </g>
                  <text x="345" y="270" fill="#0B0E14" fontFamily="PP Object Sans" fontSize="14" fontWeight="500" letterSpacing="0.1em">RANK #1</text>
                  <text x="40" y="80" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="46" letterSpacing="-1">PLP relevancy</text>
                  <text x="40" y="120" fill="#9CA3B4" fontFamily="PP Object Sans" fontWeight="300" fontSize="18">Ranking that earns its top slot</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>A relevancy algorithm for product listing pages</h3>
                <p>
                  How I designed and shipped a new ranking model for Tira&apos;s PLP grids —
                  combining behavioural signals, freshness and merchandising constraints
                  — and cut bounce rates by 7–10% across category pages.
                </p>
                <div className="proj__foot">
                  <span>Tira (Reliance) · 2024</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            <Link className="proj is-third" href="/case/attribution">
              <div className="proj__cover">
                <span className="label">Case study · Tira</span>
                <span className="year">2023</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#11141C" />
                  <g stroke="#E0B973" strokeWidth="1" fill="none" opacity="0.7">
                    <circle cx="60" cy="60" r="18" />
                    <circle cx="60" cy="120" r="18" />
                    <circle cx="60" cy="180" r="18" />
                    <circle cx="340" cy="120" r="22" fill="#E0B973" stroke="#E0B973" />
                    <path d="M78 60 C 180 60, 220 120, 318 120" />
                    <path d="M78 120 L 318 120" />
                    <path d="M78 180 C 180 180, 220 120, 318 120" />
                  </g>
                  <text x="30" y="220" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="22">Attribution model</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>An attribution model the whole org actually uses</h3>
                <p>
                  A SQL-native multi-touch attribution model in BigQuery that serves
                  Marketing, Branding and Strategy from a single source of truth.
                </p>
                <div className="proj__foot">
                  <span>Tira · 2023</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            <Link className="proj is-third" href="/case/ott-dashboard">
              <div className="proj__cover">
                <span className="label">Case study · MiQ</span>
                <span className="year">2021</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#0E1118" />
                  <g stroke="#E0B973" strokeWidth="1" fill="none" opacity="0.6">
                    <rect x="40" y="40" width="320" height="160" rx="6" />
                    <line x1="40" y1="80" x2="360" y2="80" />
                    <rect x="60" y="100" width="60" height="80" fill="#ECEEF3" stroke="none" opacity="0.5" />
                    <rect x="140" y="120" width="60" height="60" fill="#ECEEF3" stroke="none" opacity="0.3" />
                    <rect x="220" y="90" width="60" height="90" fill="#E0B973" stroke="#E0B973" />
                    <rect x="300" y="140" width="40" height="40" fill="#ECEEF3" stroke="none" opacity="0.2" />
                  </g>
                  <text x="60" y="68" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="14" letterSpacing="0.1em">OTT INSIGHTS · POST-CAMPAIGN</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Post-campaign OTT insights, automated</h3>
                <p>
                  A dashboard that ingests 20+ first/second/third-party feeds and
                  produces 10+ reports per campaign — and contributed $5M in business
                  for MiQ.
                </p>
                <div className="proj__foot">
                  <span>MiQ Digital · 2021</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            <a className="proj is-half" href="#" onClick={(e) => e.preventDefault()}>
              <div className="proj__cover">
                <span className="label">Case · Threedots</span>
                <span className="year">2022</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#11141C" />
                  <g fill="none" stroke="#E0B973" strokeWidth="1.2" opacity="0.7">
                    <circle cx="200" cy="120" r="80" />
                    <circle cx="200" cy="120" r="56" opacity="0.55" />
                    <circle cx="200" cy="120" r="32" opacity="0.3" />
                  </g>
                  <circle cx="200" cy="120" r="8" fill="#E0B973" />
                  <text x="40" y="220" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="18">Fraud pattern detection</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Fraud detection in a gaming-rewards app</h3>
                <p>
                  Pattern detection on user behaviour that cut daily incentive payout by
                  15% — without touching the legitimate user experience. Write-up in
                  progress.
                </p>
                <div className="proj__foot">
                  <span>Threedots · 2022</span>
                  <span className="arrow">Coming soon</span>
                </div>
              </div>
            </a>

            <a className="proj is-half" href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer">
              <div className="proj__cover">
                <span className="label">Writing</span>
                <span className="year">Blog</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#0E1118" />
                  <text x="40" y="100" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="34" letterSpacing="-1">&ldquo;Connected TV —</text>
                  <text x="40" y="142" fill="#E0B973" fontFamily="PP Object Sans" fontWeight="300" fontSize="34" fontStyle="italic" letterSpacing="-1">a disruption in</text>
                  <text x="40" y="184" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="34" letterSpacing="-1">digital advertising.&rdquo;</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Connected TV — a disruption in digital advertising</h3>
                <p>
                  A Medium essay on how CTV is quietly reshaping attribution, measurement
                  and creative for digital advertising. Written off the back of three
                  years inside MiQ.
                </p>
                <div className="proj__foot">
                  <span>Medium · Essay</span>
                  <span className="arrow">Read →</span>
                </div>
              </div>
            </a>
          </div>
        </div>
      </main>

      <Footer nextHref="/achievements" nextLabel="Achievements" backHref="/experience" backLabel="Experience" />
    </>
  );
}
