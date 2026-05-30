"use client";
import Nav from "../components/Nav";
import Footer from "../components/Footer";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function About() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <header className="page-head">
        <div className="wrap page-head__inner reveal">
          <div>
            <div className="crumb"><span />01 · About</div>
            <h1>A short<br /><em>introduction.</em></h1>
          </div>
          <p className="lede">
            I started in adtech analytics, moved through gaming and fintech, and for
            the last three years I&apos;ve been close to the product at Tira — Reliance&apos;s
            beauty marketplace.
          </p>
        </div>
      </header>

      <main className="page-body">
        <div className="wrap">
          <div className="about__grid">
            <div className="about__body reveal">
              <p>
                My work sits at the intersection of data mining, statistical analysis
                and product decision-making. I&apos;m happiest when a vague worry from a PM
                (&ldquo;ranking feels off&rdquo;, &ldquo;attribution looks wrong&rdquo;) ends with a measurable
                answer — a relevancy model, an attribution framework, a clean A/B read-out.
              </p>
              <p>
                I read SQL and Python before I read my emails, and I care more about
                the question than the tool. When I&apos;m not at a notebook, I&apos;m writing —
                most recently a piece on Connected TV&apos;s quiet disruption of the digital
                advertising landscape.
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

        <div className="wrap" style={{ marginTop: "clamp(56px, 8vw, 112px)" }}>
          <div className="section__head reveal">
            <div>
              <div className="section__num"><span />Toolkit</div>
              <h2 className="section__title">Tools, methods,<br />and a few opinions.</h2>
            </div>
            <p className="section__lede">
              I care more about the question than the tool. That said, here are the ones I reach for most.
            </p>
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
      </main>

      <Footer nextHref="/academics" nextLabel="Academics" backHref="/" backLabel="Home" />
    </>
  );
}
