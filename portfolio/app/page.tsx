"use client";
import { useEffect } from "react";
import Link from "next/link";

export default function Home() {
  useEffect(() => {
    // Tweaks panel
    const tweaks: Record<string, string> = { palette: "default", density: "default", hero: "split" };

    function applyTweaks() {
      document.body.dataset.palette = tweaks.palette;
      document.body.dataset.density = tweaks.density;
      const grid = document.querySelector(".hero__grid") as HTMLElement | null;
      if (grid) {
        if (tweaks.hero === "stack") {
          grid.style.gridTemplateColumns = "1fr";
          grid.style.maxWidth = "880px";
          grid.style.margin = "0 auto";
        } else {
          grid.style.gridTemplateColumns = "";
          grid.style.maxWidth = "";
          grid.style.margin = "";
        }
      }
      document.querySelectorAll("[data-tweak] button, [data-tweak] .sw").forEach((b) => {
        const el = b as HTMLElement;
        const parent = el.closest("[data-tweak]") as HTMLElement | null;
        if (!parent) return;
        const key = parent.dataset.tweak!;
        el.classList.toggle("is-active", el.dataset.value === tweaks[key]);
      });
    }

    function setTweak(key: string, value: string) {
      tweaks[key] = value;
      applyTweaks();
      try { window.parent.postMessage({ type: "__edit_mode_set_keys", edits: { [key]: value } }, "*"); } catch {}
    }

    document.querySelectorAll("[data-tweak]").forEach((group) => {
      group.addEventListener("click", (e) => {
        const btn = (e.target as HTMLElement).closest("button, .sw") as HTMLElement | null;
        if (!btn || !btn.dataset.value) return;
        const parent = btn.closest("[data-tweak]") as HTMLElement;
        setTweak(parent.dataset.tweak!, btn.dataset.value);
      });
    });

    applyTweaks();

    const panel = document.getElementById("tweaks");
    window.addEventListener("message", (e) => {
      if (!e.data || !e.data.type) return;
      if (e.data.type === "__activate_edit_mode") panel?.classList.add("is-open");
      if (e.data.type === "__deactivate_edit_mode") panel?.classList.remove("is-open");
    });
    document.getElementById("tweaks-close")?.addEventListener("click", () => {
      panel?.classList.remove("is-open");
      try { window.parent.postMessage({ type: "__edit_mode_dismissed" }, "*"); } catch {}
    });
    try { window.parent.postMessage({ type: "__edit_mode_available" }, "*"); } catch {}

    // Scroll reveal
    const io = new IntersectionObserver(
      (entries) => entries.forEach((en) => { if (en.isIntersecting) { en.target.classList.add("is-visible"); io.unobserve(en.target); } }),
      { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
    );
    document.querySelectorAll(".reveal, .reveal-stagger").forEach((el) => io.observe(el));
    return () => io.disconnect();
  }, []);

  return (
    <>
      {/* NAV */}
      <nav className="nav">
        <div className="wrap nav__inner">
          <Link href="/" className="nav__brand">
            <span className="dot"></span>
            Shubham Bansla
            <small>Product analyst</small>
          </Link>
          <div className="nav__links">
            <a href="#about">About</a>
            <a href="#academics">Academics</a>
            <a href="#experience">Experience</a>
            <a href="#work">Work</a>
            <a href="#achievements">Achievements</a>
          </div>
          <a href="#contact" className="nav__cta">Get in touch</a>
        </div>
      </nav>

      {/* HERO */}
      <header className="hero">
        <div className="wrap hero__grid">
          <div className="hero__portrait reveal" data-comment-anchor="hero-portrait">
            <div className="initials">SB</div>
            <div className="stripe">
              <span>2026</span>
              <span>Gurugram, IN</span>
            </div>
            <div className="badge">Product analyst</div>
          </div>
          <div className="hero__intro reveal" data-comment-anchor="hero-intro">
            <div className="eyebrow">Portfolio · Product analytics</div>
            <h1 className="hero__title">
              Six years of<br />
              finding the signal<br />
              <em>inside the noise.</em>
            </h1>
            <p className="hero__lede">
              I&apos;m Shubham, a product analyst working across e-commerce, digital
              advertising, gaming and fintech. I build the dashboards, models and
              experiments that help product teams move from a hunch to a number —
              and back to a decision.
            </p>
            <div className="hero__meta">
              <div><b>6+ yrs</b> in analytics</div>
              <div><b>4 industries</b> shipped</div>
              <div><b>$5M+</b> business influenced</div>
            </div>
          </div>
        </div>
      </header>

      {/* MARQUEE */}
      <div className="marquee" aria-hidden="true">
        <div className="marquee__track">
          <span>Python <em>·</em> PySpark <em>·</em> SQL <em>·</em> BigQuery <em>·</em> Mixpanel <em>·</em> GA4 <em>·</em> A/B testing <em>·</em> Attribution <em>·</em> Clustering <em>·</em></span>
          <span>Python <em>·</em> PySpark <em>·</em> SQL <em>·</em> BigQuery <em>·</em> Mixpanel <em>·</em> GA4 <em>·</em> A/B testing <em>·</em> Attribution <em>·</em> Clustering <em>·</em></span>
        </div>
      </div>

      {/* ABOUT */}
      <section id="about" className="section">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>01 · About</div>
              <h2 className="section__title">A short<br />introduction.</h2>
            </div>
            <p className="section__lede">
              I started in adtech analytics, moved through gaming and fintech, and
              for the last three years I&apos;ve been close to the product at Tira —
              Reliance&apos;s beauty marketplace.
            </p>
          </div>
          <div className="about__grid">
            <div className="about__body reveal">
              <p>
                My work sits at the intersection of data mining, statistical
                analysis and product decision-making. I&apos;m happiest when a vague
                worry from a PM (&ldquo;ranking feels off&rdquo;, &ldquo;attribution looks wrong&rdquo;)
                ends with a measurable answer — a relevancy model, an attribution
                framework, a clean A/B read-out.
              </p>
              <p>
                I read SQL and Python before I read my emails, and I care more
                about the question than the tool. When I&apos;m not at a notebook,
                I&apos;m writing — most recently a piece on Connected TV&apos;s quiet
                disruption of the digital advertising landscape.
              </p>
            </div>
            <div className="about__stats reveal-stagger">
              <div className="stat"><span className="num">$5<sup>M</sup></span><div className="label">OTT dashboard impact</div></div>
              <div className="stat"><span className="num">10<sup>%</sup></span><div className="label">Bounce reduction (PLP)</div></div>
              <div className="stat"><span className="num">15<sup>%</sup></span><div className="label">Fraud incentive saved</div></div>
              <div className="stat"><span className="num">30<sup>%</sup></span><div className="label">Acquisition uplift (Swoo)</div></div>
            </div>
          </div>
        </div>
      </section>

      {/* ACADEMICS */}
      <section id="academics" className="section section--blush">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>02 · Academics</div>
              <h2 className="section__title">Where I<br />learned to think.</h2>
            </div>
            <p className="section__lede">
              A mechanical-engineering start, an MBA, and then two specialised
              programmes that pulled me firmly into data science and statistics.
            </p>
          </div>
          <div className="timeline">
            <div className="tl-row reveal">
              <div className="when">2021 – 2022</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Post Graduate Diploma in Applied Statistics</h4>
                <p className="where">Indira Gandhi National Open University (IGNOU)</p>
                <p className="body">Formal grounding in inferential statistics, regression and experimental design — the layer beneath every dashboard I build.</p>
                <div className="chips">
                  <span className="chip">Statistics</span>
                  <span className="chip">Regression</span>
                  <span className="chip">Experimental design</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2018 – 2019</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Post Graduate Program in Data Science</h4>
                <p className="where">Praxis Business School, Bengaluru</p>
                <p className="body">Industry-focused programme covering Python, SQL, machine learning and visualisation. The pivot point that turned my MBA-and-engineering background into a product analytics career.</p>
                <div className="chips">
                  <span className="chip">Python</span>
                  <span className="chip">SQL</span>
                  <span className="chip">Machine learning</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2016 – 2018</div>
              <div className="mark"></div>
              <div className="what">
                <h4>MBA, Marketing &amp; Operations</h4>
                <p className="where">Dr. A.P.J. Abdul Kalam Technical University, Uttar Pradesh</p>
                <p className="body">Where I picked up the language of business — marketing funnels, operations, P&amp;L thinking — that I now pair with the data side every day.</p>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2012 – 2016</div>
              <div className="mark"></div>
              <div className="what">
                <h4>B.Tech, Mechanical Engineering</h4>
                <p className="where">Dr. A.P.J. Abdul Kalam Technical University, Uttar Pradesh</p>
                <p className="body">Four years of first-principles thinking. Looking back, the habit of breaking a system down into its parts is the thing I carry forward most.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* EXPERIENCE */}
      <section id="experience" className="section">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>03 · Experience</div>
              <h2 className="section__title">Where the<br />work has happened.</h2>
            </div>
            <p className="section__lede">
              Six years of product analytics, across digital advertising at MiQ,
              gaming at Swoo and Threedots, and beauty e-commerce at Tira.
            </p>
          </div>
          <div className="timeline">
            <div className="tl-row reveal">
              <div className="when">Mar 2023 – Now</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Product Analyst — Jio Beauty (Tira)</h4>
                <p className="where">Reliance · Gurugram</p>
                <p className="body">Built a relevancy algorithm for PLP product ranking (−7 to −10% bounce), shipped a SQL-based attribution model in BigQuery used by Marketing, Branding and Strategy, and partnered with UX on a loyalty-journey A/B test that lifted Treats product engagement by 10%.</p>
                <div className="chips">
                  <span className="chip">Ranking</span>
                  <span className="chip">Attribution</span>
                  <span className="chip">A/B testing</span>
                  <span className="chip">BigQuery · SQL</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">May 2022 – Feb 2023</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Product Analyst — Threedots</h4>
                <p className="where">Bengaluru</p>
                <p className="body">Built fraud-detection logic that cut daily incentive spend by 15%, automated PM reporting via BigQuery Scheduler (−20% weekly load), and surfaced cross-vertical behavioural insights using decision-tree techniques to lift retention.</p>
                <div className="chips">
                  <span className="chip">Fraud detection</span>
                  <span className="chip">Automation</span>
                  <span className="chip">Decision trees</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">Sept 2019 – Apr 2022</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Product Analyst — MiQ Digital India</h4>
                <p className="where">Bengaluru</p>
                <p className="body">Built automated post-campaign OTT insights dashboards that contributed $5M in business — a single product analysing 20+ feeds across first-, second- and third-party data and producing 10+ reports. Ran uplift brand studies using A/B testing for major clients.</p>
                <div className="chips">
                  <span className="chip">OTT</span>
                  <span className="chip">Dashboards</span>
                  <span className="chip">Brand uplift</span>
                  <span className="chip">Periscope</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">Apr 2019 – Aug 2019</div>
              <div className="mark"></div>
              <div className="what">
                <h4>Product Analyst — Swoo (ADFG Tech India)</h4>
                <p className="where">Bengaluru</p>
                <p className="body">Segmented users with k-means clustering for the marketing team — drove a 30% improvement in customer acquisition. Owned the vertical-wise product-health dashboards and weekly insight cadence.</p>
                <div className="chips">
                  <span className="chip">K-means</span>
                  <span className="chip">Segmentation</span>
                  <span className="chip">Reporting</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* WORK / PROJECTS */}
      <section id="work" className="section section--blush">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>04 · Selected work</div>
              <h2 className="section__title">A few projects,<br />told properly.</h2>
            </div>
            <p className="section__lede">
              I&apos;d rather walk you through three pieces of work end-to-end than
              flash twenty thumbnails. Click any tile for the case study.
            </p>
          </div>
          <div className="projects reveal-stagger">
            {/* Featured */}
            <Link className="proj is-feat" href="/case/relevancy">
              <div className="proj__cover">
                <span className="label">Case study · Tira</span>
                <span className="year">2024</span>
                <svg className="cover-svg" viewBox="0 0 800 360" preserveAspectRatio="none">
                  <defs>
                    <linearGradient id="g1" x1="0" y1="0" x2="1" y2="1">
                      <stop offset="0" stopColor="#FCF2EF" />
                      <stop offset="1" stopColor="#F8E1D9" />
                    </linearGradient>
                  </defs>
                  <rect width="800" height="360" fill="url(#g1)" />
                  <g stroke="#211A1E" strokeWidth="1.2" fill="none">
                    <rect x="40" y="180" width="120" height="150" />
                    <rect x="180" y="180" width="120" height="150" />
                    <rect x="320" y="180" width="120" height="150" fill="#F11A00" stroke="#F11A00" />
                    <rect x="460" y="180" width="120" height="150" />
                    <rect x="600" y="180" width="120" height="150" />
                  </g>
                  <g fill="#FFF" fontFamily="PP Object Sans" fontSize="14" fontWeight="500" letterSpacing="0.1em">
                    <text x="345" y="270">RANK #1</text>
                  </g>
                  <text x="40" y="80" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="46" letterSpacing="-1">PLP relevancy</text>
                  <text x="40" y="120" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="300" fontSize="18">Ranking that earns its top slot</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>A relevancy algorithm for product listing pages</h3>
                <p>How I designed and shipped a new ranking model for Tira&apos;s PLP grids — combining behavioural signals, freshness and merchandising constraints — and cut bounce rates by 7–10% across category pages.</p>
                <div className="proj__foot">
                  <span>Tira (Reliance) · 2024</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            {/* Attribution */}
            <Link className="proj is-third" href="/case/attribution">
              <div className="proj__cover">
                <span className="label">Case study · Tira</span>
                <span className="year">2023</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#FFF" />
                  <g stroke="#211A1E" strokeWidth="1" fill="none">
                    <circle cx="60" cy="60" r="18" />
                    <circle cx="60" cy="120" r="18" />
                    <circle cx="60" cy="180" r="18" />
                    <circle cx="340" cy="120" r="22" fill="#F11A00" stroke="#F11A00" />
                    <path d="M78 60 C 180 60, 220 120, 318 120" />
                    <path d="M78 120 L 318 120" />
                    <path d="M78 180 C 180 180, 220 120, 318 120" />
                  </g>
                  <text x="30" y="220" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="22">Attribution model</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>An attribution model the whole org actually uses</h3>
                <p>A SQL-native multi-touch attribution model in BigQuery that serves Marketing, Branding and Strategy from a single source of truth.</p>
                <div className="proj__foot">
                  <span>Tira · 2023</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            {/* OTT */}
            <Link className="proj is-third" href="/case/ott-dashboard">
              <div className="proj__cover">
                <span className="label">Case study · MiQ</span>
                <span className="year">2021</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#FCF2EF" />
                  <g stroke="#211A1E" strokeWidth="1" fill="none">
                    <rect x="40" y="40" width="320" height="160" rx="6" />
                    <line x1="40" y1="80" x2="360" y2="80" />
                    <rect x="60" y="100" width="60" height="80" fill="#211A1E" />
                    <rect x="140" y="120" width="60" height="60" fill="#211A1E" opacity="0.6" />
                    <rect x="220" y="90" width="60" height="90" fill="#F11A00" stroke="#F11A00" />
                    <rect x="300" y="140" width="40" height="40" fill="#211A1E" opacity="0.4" />
                  </g>
                  <text x="60" y="68" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="14" letterSpacing="0.1em">OTT INSIGHTS · POST-CAMPAIGN</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Post-campaign OTT insights, automated</h3>
                <p>A dashboard that ingests 20+ first/second/third-party feeds and produces 10+ reports per campaign — and contributed $5M in business for MiQ.</p>
                <div className="proj__foot">
                  <span>MiQ Digital · 2021</span>
                  <span className="arrow">Read case →</span>
                </div>
              </div>
            </Link>

            {/* Fraud */}
            <a className="proj is-half" href="#" onClick={(e) => e.preventDefault()}>
              <div className="proj__cover">
                <span className="label">Case · Threedots</span>
                <span className="year">2022</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#F7F7F7" />
                  <g fill="none" stroke="#211A1E" strokeWidth="1.2">
                    <circle cx="200" cy="120" r="80" />
                    <circle cx="200" cy="120" r="56" opacity="0.55" />
                    <circle cx="200" cy="120" r="32" opacity="0.3" />
                  </g>
                  <circle cx="200" cy="120" r="8" fill="#F11A00" />
                  <text x="40" y="220" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="18">Fraud pattern detection</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Fraud detection in a gaming-rewards app</h3>
                <p>Pattern detection on user behaviour that cut daily incentive payout by 15% — without touching the legitimate user experience. Write-up in progress.</p>
                <div className="proj__foot">
                  <span>Threedots · 2022</span>
                  <span className="arrow">Coming soon</span>
                </div>
              </div>
            </a>

            {/* Essay */}
            <a className="proj is-half" href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer">
              <div className="proj__cover">
                <span className="label">Writing</span>
                <span className="year">Blog</span>
                <svg className="cover-svg" viewBox="0 0 400 240" preserveAspectRatio="none">
                  <rect width="400" height="240" fill="#FFF" />
                  <text x="40" y="100" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="34" letterSpacing="-1">&ldquo;Connected TV —</text>
                  <text x="40" y="142" fill="#F11A00" fontFamily="PP Object Sans" fontWeight="300" fontSize="34" fontStyle="italic" letterSpacing="-1">a disruption in</text>
                  <text x="40" y="184" fill="#211A1E" fontFamily="PP Object Sans" fontWeight="500" fontSize="34" letterSpacing="-1">digital advertising.&rdquo;</text>
                </svg>
              </div>
              <div className="proj__body">
                <h3>Connected TV — a disruption in digital advertising</h3>
                <p>A Medium essay on how CTV is quietly reshaping attribution, measurement and creative for digital advertising. Written off the back of three years inside MiQ.</p>
                <div className="proj__foot">
                  <span>Medium · Essay</span>
                  <span className="arrow">Read →</span>
                </div>
              </div>
            </a>
          </div>
        </div>
      </section>

      {/* ACHIEVEMENTS */}
      <section id="achievements" className="section">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>05 · Certifications &amp; recognition</div>
              <h2 className="section__title">A few moments<br />worth marking.</h2>
            </div>
            <p className="section__lede">Certifications I&apos;ve earned, work I&apos;m quietly proud of, and the blog post I still occasionally re-read.</p>
          </div>
          <div className="achievements">
            <div className="ach reveal"><div className="yr">2024</div><div className="txt"><h4>10% lift in Treats engagement at Tira</h4><p>A/B test on the user loyalty journey, partnered with UX/UI.</p></div></div>
            <div className="ach reveal"><div className="yr">2023</div><div className="txt"><h4>PLP bounce rate down 7–10%</h4><p>Built and shipped a new relevancy algorithm for Tira product listing pages.</p></div></div>
            <div className="ach reveal"><div className="yr">2022</div><div className="txt"><h4>Fraud detection at Threedots</h4><p>Cut daily incentive outflow by 15% through behavioural pattern detection.</p></div></div>
            <div className="ach reveal"><div className="yr">2021</div><div className="txt"><h4>$5M business contribution at MiQ</h4><p>Built the automated post-campaign OTT insights dashboard ecosystem.</p></div></div>
            <div className="ach reveal"><div className="yr">—</div><div className="txt"><h4>Published on Medium — &ldquo;Connected TV: A disruption in digital advertising&rdquo;</h4><p>An essay on attribution, measurement and creative in the CTV era.</p></div></div>
            <div className="ach reveal"><div className="yr">—</div><div className="txt"><h4>Certifications</h4><p>Coursera — &ldquo;Exploring &amp; preparing your data with BigQuery&rdquo; (E2NEQKMGAYB3). Google — Campaign Manager (49259709), Display &amp; Video 360.</p></div></div>
          </div>
        </div>
      </section>

      {/* SKILLS */}
      <section className="section section--blush">
        <div className="wrap">
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span></span>06 · Toolkit</div>
              <h2 className="section__title">Tools, methods,<br />and a few opinions.</h2>
            </div>
            <p className="section__lede">I care more about the question than the tool. That said, here are the ones I reach for most.</p>
          </div>
          <div className="skills reveal-stagger">
            <span className="skill">SQL <span className="dim">Every day</span></span>
            <span className="skill">Python <span className="dim">Every day</span></span>
            <span className="skill">PySpark</span>
            <span className="skill">BigQuery</span>
            <span className="skill">Databricks</span>
            <span className="skill">Mixpanel</span>
            <span className="skill">Amplitude</span>
            <span className="skill">GA4 (Google Analytics 4)</span>
            <span className="skill">Looker Studio</span>
            <span className="skill">A/B testing</span>
            <span className="skill">Attribution modelling</span>
            <span className="skill">K-means clustering</span>
            <span className="skill">Logistic regression</span>
            <span className="skill">Decision trees</span>
            <span className="skill">Jira · Asana</span>
            <span className="skill">Product lifecycle</span>
            <span className="skill">Stakeholder management</span>
          </div>
        </div>
      </section>

      {/* CONTACT */}
      <section id="contact" className="contact">
        <div className="wrap">
          <h2 className="contact__big reveal">
            Have a tricky<br />
            question to <em>untangle?</em><br />
            <a href="mailto:Shubhambansla95@gmail.com">Shubhambansla95@gmail.com</a>
          </h2>
          <div className="contact__grid reveal-stagger">
            <a href="mailto:Shubhambansla95@gmail.com"><span className="k">Email</span><span className="v">Shubhambansla95@gmail.com</span></a>
            <a href="tel:+919958852491"><span className="k">Phone</span><span className="v">+91 99588 52491</span></a>
            <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer"><span className="k">LinkedIn</span><span className="v">in/shubham-bansla</span></a>
            <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer"><span className="k">Writing</span><span className="v">Medium · CTV essay</span></a>
          </div>
          <div className="contact__foot">
            <div>© 2026 Shubham Bansla</div>
            <div>Made with intent, in Gurugram.</div>
          </div>
        </div>
      </section>

      {/* TWEAKS PANEL */}
      <div className="tweaks" id="tweaks">
        <div className="tweaks__head">
          <h5>Tweaks</h5>
          <button className="tweaks__close" id="tweaks-close" aria-label="Close">✕</button>
        </div>
        <div className="group">
          <label>Palette</label>
          <div className="swatches" data-tweak="palette">
            <button className="sw is-active" data-value="default" style={{ background: "linear-gradient(45deg,#FCF2EF 50%,#F11A00 50%)" }} aria-label="Default coral"></button>
            <button className="sw" data-value="wine" style={{ background: "linear-gradient(45deg,#FCF2EF 50%,#C04657 50%)" }} aria-label="Wine luxe"></button>
            <button className="sw" data-value="mono" style={{ background: "linear-gradient(45deg,#FFFFFF 50%,#211A1E 50%)", borderColor: "#ddd" }} aria-label="Mono"></button>
          </div>
        </div>
        <div className="group">
          <label>Density</label>
          <div className="seg" data-tweak="density">
            <button data-value="compact">Compact</button>
            <button className="is-active" data-value="default">Default</button>
            <button data-value="airy">Airy</button>
          </div>
        </div>
        <div className="group">
          <label>Hero layout</label>
          <div className="seg" data-tweak="hero">
            <button className="is-active" data-value="split">Split</button>
            <button data-value="stack">Stack</button>
          </div>
        </div>
      </div>
    </>
  );
}
