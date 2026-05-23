"use client";
import { useEffect } from "react";
import Link from "next/link";
import Nav from "../../components/Nav";

export default function CaseOttDashboard() {
  useEffect(() => {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((en) => {
          if (en.isIntersecting) {
            en.target.classList.add("is-visible");
            io.unobserve(en.target);
          }
        });
      },
      { threshold: 0.12 }
    );
    document.querySelectorAll(".reveal, .reveal-stagger").forEach((el) => io.observe(el));
    return () => io.disconnect();
  }, []);

  return (
    <>
      <Nav />
      <main className="case">
        <header className="case__hero">
          <div className="wrap">
            <Link href="/#work" className="case__back">← Back to selected work</Link>
            <div className="section__num"><span></span>Case 03 · Dashboards</div>
            <h1 className="case__title">Post-campaign OTT<br />insights, automated.</h1>
            <p className="case__lede">
              An automated dashboard ecosystem that ingests 20+ first-, second-
              and third-party feeds and produces 10+ post-campaign reports — and
              contributed $5M in business for MiQ.
            </p>
            <div className="case__meta">
              <div><div className="k">Company</div><div className="v">MiQ Digital India</div></div>
              <div><div className="k">Role</div><div className="v">Product analyst, dashboard owner</div></div>
              <div><div className="k">Timeline</div><div className="v">2020 – 2022</div></div>
              <div><div className="k">Stack</div><div className="v">SQL · Periscope · BigQuery</div></div>
            </div>
          </div>
        </header>

        <div className="wrap">
          <div className="case__cover">
            <svg className="cover-svg" viewBox="0 0 1200 540" preserveAspectRatio="none">
              <rect width="1200" height="540" fill="#FCF2EF" />
              <g stroke="#211A1E" strokeWidth="1.5" fill="#FFF">
                <rect x="80" y="80" width="1040" height="400" rx="8" />
              </g>
              <line x1="80" y1="130" x2="1120" y2="130" stroke="#211A1E" strokeWidth="1.5" />
              <g fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="14" letterSpacing="0.12em">
                <text x="100" y="116">OTT INSIGHTS · CAMPAIGN ROLL-UP</text>
              </g>
              <g>
                <rect x="100" y="160" width="220" height="140" fill="#211A1E" />
                <rect x="100" y="320" width="220" height="140" fill="#211A1E" opacity="0.2" />
                <rect x="340" y="160" width="220" height="300" fill="#F11A00" />
                <rect x="580" y="160" width="220" height="140" fill="#211A1E" opacity="0.6" />
                <rect x="580" y="320" width="220" height="140" fill="#211A1E" opacity="0.35" />
                <rect x="820" y="160" width="280" height="140" fill="#211A1E" opacity="0.85" />
                <rect x="820" y="320" width="280" height="140" fill="#211A1E" opacity="0.15" />
              </g>
              <text x="370" y="320" fill="#FFF" fontFamily="PP Object Sans" fontWeight="500" fontSize="48" letterSpacing="-1">$5M</text>
              <text x="370" y="350" fill="#FFF" fontFamily="PP Object Sans" fontWeight="400" fontSize="14" letterSpacing="0.12em">BUSINESS CONTRIBUTION</text>
            </svg>
          </div>

          <div className="case__body">
            <div className="case__sidenote">
              01 · The setting<br />02 · The problem<br />03 · The build<br />04 · What it produces<br />05 · Impact<br />06 · Lessons
            </div>
            <div>
              <div className="case__section">
                <h2>The setting.</h2>
                <p>
                  MiQ is a programmatic-media partner — agencies and brands run
                  CTV and OTT campaigns through MiQ's platform, and the value
                  arrives in the post-campaign read-out. Speed and credibility of
                  those read-outs are the product. In 2020, that work was almost
                  entirely manual.
                </p>
              </div>

              <div className="case__section">
                <h2>The problem.</h2>
                <p>
                  Each campaign generated a different bundle of files —
                  impressions feed, audience-overlap feed, frequency data, brand
                  study panels, third-party verification. Twenty-odd feeds on a
                  typical campaign. Solution engineers were spending two to three
                  days per campaign stitching these into client-ready insight
                  decks. The team couldn't scale, and the slowest reports were
                  often the ones with the largest media spend behind them.
                </p>
              </div>

              <div className="case__section">
                <h2>The build.</h2>
                <ul>
                  <li><b>A canonical campaign schema.</b><span>One table per campaign with foreign keys into every feed type. Every new feed conformed to it, no exceptions.</span></li>
                  <li><b>Ingestion templates.</b><span>For each feed family — first-party, second-party, third-party — a small SQL template that mapped raw → canonical. Adding a new client meant filling a template, not writing new pipeline code.</span></li>
                  <li><b>A report library.</b><span>Ten parameterised insight modules — reach, frequency, audience overlap, brand uplift, geo, device — each ran off the canonical schema. Pick the modules a client needs, hit refresh.</span></li>
                  <li><b>A Periscope front-end.</b><span>One dashboard per campaign, generated from a template. Solution engineers could share a link in minutes, not days.</span></li>
                </ul>
              </div>

              <div className="case__section">
                <h2>What it produces.</h2>
                <p>
                  For any campaign in the system, the dashboard generates the full
                  insight bundle — campaign roll-up, audience composition,
                  frequency curve, viewability and verification, uplift study,
                  and the post-campaign client deck — all in one place, all
                  refreshable.
                </p>
              </div>

              <div className="case__section">
                <h2>Impact.</h2>
                <div className="case__metrics">
                  <div className="metric"><span className="num">$5<sup>M</sup></span><span className="lbl">Business contribution</span></div>
                  <div className="metric"><span className="num">10<sup>+</sup></span><span className="lbl">Reports per campaign</span></div>
                  <div className="metric"><span className="num">20<sup>+</sup></span><span className="lbl">Feeds standardised</span></div>
                </div>
                <p>
                  The dashboard ecosystem became a recurring lever in client
                  renewals — the speed of the post-campaign read-out was now part
                  of the pitch, not just the delivery. Internally, solution
                  engineers stopped owning data plumbing and started owning the
                  client story.
                </p>
              </div>

              <div className="case__section">
                <h2>Lessons.</h2>
                <p>
                  The biggest unlock wasn't a clever SQL trick — it was the
                  decision to standardise the feed schema. Every shortcut we took
                  on schema later cost a week of cleanup. Pay the modelling tax
                  up front, and the dashboard layer becomes the easy part. That
                  lesson is the one I've carried into every dashboard project
                  since.
                </p>
              </div>
            </div>
          </div>

          <div className="next-case">
            <div>
              <div className="label">Back to</div>
              <Link href="/case/relevancy">A relevancy algorithm for PLP ranking →</Link>
            </div>
            <Link href="/#work" className="case__back">All work</Link>
          </div>
        </div>
      </main>

      <section id="contact" className="contact">
        <div className="wrap">
          <h2 className="contact__big">
            Building an<br />
            <em>insights dashboard?</em><br />
            <a href="mailto:Shubhambansla95@gmail.com">Shubhambansla95@gmail.com</a>
          </h2>
          <div className="contact__foot">
            <div>© 2026 Shubham Bansla</div>
            <div>Made with intent, in Gurugram.</div>
          </div>
        </div>
      </section>
    </>
  );
}
