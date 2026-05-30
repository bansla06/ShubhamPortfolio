"use client";
import { useEffect, useRef } from "react";
import Link from "next/link";
import Image from "next/image";

const WORDS = ["Product Analyst", "Data Storyteller", "Experiment Designer", "Dashboard Builder"];

export default function Home() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const typedRef = useRef<HTMLElement>(null);

  useEffect(() => {
    /* ---------- Typewriter ---------- */
    const el = typedRef.current;
    if (el) {
      let w = 0, c = 0, deleting = false;
      const node = el;
      function tick() {
        const word = WORDS[w];
        if (!deleting) {
          c++;
          if (c > word.length) { deleting = true; setTimeout(tick, 1500); return; }
        } else {
          c--;
          if (c < 0) { deleting = false; w = (w + 1) % WORDS.length; c = 0; }
        }
        node.textContent = word.slice(0, Math.max(0, c));
        setTimeout(tick, deleting ? 45 : 90);
      }
      tick();
    }

    /* ---------- Journey milestone reveal ---------- */
    const milestoneIo = new IntersectionObserver((entries) => {
      entries.forEach((en) => {
        if (en.isIntersecting) { en.target.classList.add("in"); milestoneIo.unobserve(en.target); }
      });
    }, { threshold: 0.2, rootMargin: "0px 0px -60px 0px" });
    document.querySelectorAll(".milestone").forEach((el) => milestoneIo.observe(el));

    /* ---------- Canvas network background ---------- */
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let w: number, h: number, dpr: number;
    let nodes: { x: number; y: number; vx: number; vy: number; r: number }[] = [];
    let mouse = { x: -9999, y: -9999 };
    let rafId: number;

    function resize() {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      w = canvas!.width = window.innerWidth * dpr;
      h = canvas!.height = window.innerHeight * dpr;
      canvas!.style.width = window.innerWidth + "px";
      canvas!.style.height = window.innerHeight + "px";
      init();
    }

    function init() {
      const count = Math.min(90, Math.floor((window.innerWidth * window.innerHeight) / 16000));
      nodes = [];
      for (let i = 0; i < count; i++) {
        nodes.push({
          x: Math.random() * w, y: Math.random() * h,
          vx: (Math.random() - 0.5) * 0.25 * dpr,
          vy: (Math.random() - 0.5) * 0.25 * dpr,
          r: (Math.random() * 1.6 + 0.6) * dpr,
        });
      }
    }

    const LINK = 150;
    function frame() {
      ctx!.clearRect(0, 0, w, h);
      const link = LINK * dpr;
      for (let i = 0; i < nodes.length; i++) {
        const n = nodes[i];
        n.x += n.vx; n.y += n.vy;
        if (n.x < 0 || n.x > w) n.vx *= -1;
        if (n.y < 0 || n.y > h) n.vy *= -1;
        for (let j = i + 1; j < nodes.length; j++) {
          const m = nodes[j];
          const dx = n.x - m.x, dy = n.y - m.y;
          const d = Math.hypot(dx, dy);
          if (d < link) {
            const a = (1 - d / link) * 0.18;
            ctx!.strokeStyle = `rgba(224,185,115,${a})`;
            ctx!.lineWidth = 1 * dpr;
            ctx!.beginPath(); ctx!.moveTo(n.x, n.y); ctx!.lineTo(m.x, m.y); ctx!.stroke();
          }
        }
        const mdx = n.x - mouse.x, mdy = n.y - mouse.y;
        const md = Math.hypot(mdx, mdy);
        if (md < link * 1.5) {
          const a = (1 - md / (link * 1.5)) * 0.4;
          ctx!.strokeStyle = `rgba(224,185,115,${a})`;
          ctx!.lineWidth = 1 * dpr;
          ctx!.beginPath(); ctx!.moveTo(n.x, n.y); ctx!.lineTo(mouse.x, mouse.y); ctx!.stroke();
        }
        ctx!.fillStyle = "rgba(236,238,243,0.55)";
        ctx!.beginPath(); ctx!.arc(n.x, n.y, n.r, 0, Math.PI * 2); ctx!.fill();
      }
      rafId = requestAnimationFrame(frame);
    }

    function onMouseMove(e: MouseEvent) { mouse.x = e.clientX * dpr; mouse.y = e.clientY * dpr; }
    function onMouseLeave() { mouse.x = -9999; mouse.y = -9999; }

    window.addEventListener("resize", resize);
    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseleave", onMouseLeave);
    resize();
    frame();

    return () => {
      cancelAnimationFrame(rafId);
      milestoneIo.disconnect();
      window.removeEventListener("resize", resize);
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("mouseleave", onMouseLeave);
    };
  }, []);

  return (
    <>
      <canvas ref={canvasRef} id="bg" />
      <div className="glow a" />
      <div className="glow b" />
      <div className="glow c" />
      <div className="vignette" />

      {/* Top bar */}
      <div className="topbar">
        <div className="brand"><span className="dot" />Shubham Bansla</div>
        <div className="topbar__right">
          <nav className="topbar__nav">
            <Link href="/about">About</Link>
            <Link href="/academics">Academics</Link>
            <Link href="/experience">Experience</Link>
            <Link href="/work">Work</Link>
          </nav>
          <span className="topbar__div" />
          <div className="topbar__social">
            <a href="https://github.com/bansla06" target="_blank" rel="noopener noreferrer" title="GitHub" aria-label="GitHub">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 .5C5.73.5.5 5.73.5 12c0 5.08 3.29 9.39 7.86 10.91.58.11.79-.25.79-.56 0-.27-.01-1.16-.02-2.1-3.2.69-3.88-1.37-3.88-1.37-.52-1.33-1.28-1.69-1.28-1.69-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.71 1.26 3.37.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.69 0-1.26.45-2.29 1.19-3.1-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.18 1.18a11 11 0 0 1 2.9-.39c.98 0 1.97.13 2.9.39 2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.84 1.19 3.1 0 4.42-2.69 5.39-5.25 5.68.41.36.78 1.06.78 2.14 0 1.55-.01 2.8-.01 3.18 0 .31.21.68.8.56A11.51 11.51 0 0 0 23.5 12C23.5 5.73 18.27.5 12 .5z" /></svg>
            </a>
            <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer" title="LinkedIn" aria-label="LinkedIn">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.45 20.45h-3.56v-5.57c0-1.33-.02-3.04-1.85-3.04-1.85 0-2.14 1.45-2.14 2.94v5.67H9.35V9h3.42v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.55V9h3.57v11.45zM22.22 0H1.77C.8 0 0 .78 0 1.74v20.52C0 23.22.8 24 1.77 24h20.45c.98 0 1.78-.78 1.78-1.74V1.74C24 .78 23.2 0 22.22 0z" /></svg>
            </a>
            <a href="mailto:Shubhambansla95@gmail.com" title="Email" aria-label="Email">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 4h20c.55 0 1 .45 1 1v14c0 .55-.45 1-1 1H2c-.55 0-1-.45-1-1V5c0-.55.45-1 1-1zm10 7.62L3.74 6H20.3L12 11.62zM3 8.27V18h18V8.27l-8.43 5.7a1 1 0 0 1-1.14 0L3 8.27z" /></svg>
            </a>
          </div>
        </div>
      </div>

      {/* Hero stage */}
      <main className="stage">
        <div className="photo-wrap">
          <div className="photo-ring" />
          <div className="photo">
            <Image src="/me.png" alt="Shubham Bansla" fill style={{ objectFit: "cover", objectPosition: "center 18%" }} priority />
          </div>
        </div>

        <div className="intro">
          <h1>Shubham<br /><span className="last">Bansla.</span></h1>
          <p className="role">I&apos;m a <b className="typed" ref={typedRef as React.RefObject<HTMLElement>}>Product Analyst</b></p>
          <p className="lede">
            Seven years turning ambiguous product questions into measurable answers —
            across e-commerce, digital advertising, gaming and fintech. I build the
            dashboards, models and experiments that move teams from a hunch to a
            number, and back to a decision.
          </p>
          <div className="cta-row">
            <Link className="btn btn--primary" href="/work">Explore my work <span className="arrow">→</span></Link>
            <a className="btn btn--ghost" href="mailto:Shubhambansla95@gmail.com">Get in touch</a>
          </div>
          <div className="quickstats">
            <div className="qs"><span className="n">7<span className="plus">+</span></span><span className="l">Years</span></div>
            <div className="qs"><span className="n">4</span><span className="l">Industries</span></div>
          </div>
        </div>

        <a className="enter-hint" href="#journey">
          My journey
          <span className="chev" />
        </a>
      </main>

      {/* Journey timeline */}
      <section className="journey" id="journey">
        <div className="journey__head">
          <div className="eyebrow">The path so far</div>
          <h2>From a mechanical drawing<br />board to product data.</h2>
          <p>
            A non-linear route — engineering, an MBA, two data-science programmes,
            and six years of analytics across four industries. Here&apos;s how it joined up.
          </p>
        </div>

        <div className="path">
          {[
            { year: "2010", title: "Class X · CBSE", where: "Secondary school", tag: "edu", tagLabel: "Schooling" },
            { year: "2012", title: "Class XII · CBSE", where: "Senior secondary · Science (PCM)", tag: "edu", tagLabel: "Schooling" },
            { year: "2012 — 2016", title: "B.Tech, Mechanical Engineering", where: "Dr. A.P.J. Abdul Kalam Technical University", tag: "edu", tagLabel: "Undergrad" },
            { year: "2016 — 2018", title: "MBA, Marketing & Operations", where: "Dr. A.P.J. Abdul Kalam Technical University", tag: "edu", tagLabel: "Postgrad" },
            { year: "2018 — 2019", title: "PG Program in Data Science", where: "Praxis Business School, Bengaluru", tag: "edu", tagLabel: "The pivot" },
            { year: "2019", title: "Product Analyst — Swoo", where: "ADFG Tech · first analytics role", tag: "work", tagLabel: "Work" },
            { year: "2019 — 2022", title: "Product Analyst — MiQ Digital", where: "Bengaluru · $5M OTT dashboards", tag: "work", tagLabel: "Work" },
            { year: "2021 — 2022", title: "PG Diploma, Applied Statistics", where: "IGNOU · alongside work", tag: "edu", tagLabel: "Postgrad" },
            { year: "2022 — 2023", title: "Product Analyst — Threedots", where: "Bengaluru · fraud detection, −15%", tag: "work", tagLabel: "Work" },
            { year: "2023 — Now", title: "Product Analyst — Jio Beauty (Tira)", where: "Reliance, Gurugram · ranking, attribution, A/B", tag: "work", tagLabel: "Current", isNow: true },
          ].map((m, i) => (
            <div key={i} className={`milestone${m.isNow ? " is-now" : ""}`}>
              <span className="node" />
              <div className="card">
                <span className="year">{m.year}</span>
                <h3>{m.title}</h3>
                <p className="where">{m.where}</p>
                <span className={`tag ${m.tag}`}>{m.tagLabel}</span>
              </div>
            </div>
          ))}
        </div>

        <div style={{ textAlign: "center", marginTop: "clamp(40px,6vw,72px)" }}>
          <Link className="btn btn--primary" href="/work">See what I built <span className="arrow">→</span></Link>
        </div>
      </section>
    </>
  );
}
