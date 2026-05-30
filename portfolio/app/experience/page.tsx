"use client";
import Nav from "../components/Nav";
import Footer from "../components/Footer";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function Experience() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <header className="page-head">
        <div className="wrap page-head__inner reveal">
          <div>
            <div className="crumb"><span />03 · Experience</div>
            <h1>Where the<br /><em>work has happened.</em></h1>
          </div>
          <p className="lede">
            Six years of product analytics, across digital advertising at MiQ, gaming
            at Swoo and Threedots, and beauty e-commerce at Tira.
          </p>
        </div>
      </header>

      <main className="page-body">
        <div className="wrap">
          <div className="timeline">
            <div className="tl-row reveal">
              <div className="when">Mar 2023 – Now</div>
              <div className="mark" />
              <div className="what">
                <h4>Product Analyst — Jio Beauty (Tira)</h4>
                <p className="where">Reliance · Gurugram</p>
                <p className="body">
                  Built a relevancy algorithm for PLP product ranking (−7 to −10%
                  bounce), shipped a SQL-based attribution model in BigQuery used by
                  Marketing, Branding and Strategy, and partnered with UX on a
                  loyalty-journey A/B test that lifted Treats product engagement by 10%.
                  Ran root-cause analysis with backend on a crash issue, preventing ~10%
                  churn, and surfaced fast-converting, profitable segments that lifted
                  orders by 5%.
                </p>
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
              <div className="mark" />
              <div className="what">
                <h4>Product Analyst — Threedots</h4>
                <p className="where">Bengaluru</p>
                <p className="body">
                  Built fraud-detection logic that cut daily incentive spend by 15% by
                  identifying behavioural patterns, automated PM reporting via BigQuery
                  Scheduler (−20% weekly load), surfaced cross-vertical insights using
                  decision trees to lift retention, and optimised SQL that took job
                  runtimes from hours to minutes.
                </p>
                <div className="chips">
                  <span className="chip">Fraud detection</span>
                  <span className="chip">Automation</span>
                  <span className="chip">Decision trees</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">Sept 2019 – Apr 2022</div>
              <div className="mark" />
              <div className="what">
                <h4>Product Analyst — MiQ Digital India</h4>
                <p className="where">Bengaluru</p>
                <p className="body">
                  Built automated post-campaign OTT insights dashboards that contributed
                  $5M in business — a single product analysing 20+ feeds across first-,
                  second- and third-party data and producing 10+ reports. Defined
                  campaign KPIs with stakeholders, ran uplift brand studies via A/B
                  testing, and maintained performance-tracking dashboards in Periscope.
                </p>
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
              <div className="mark" />
              <div className="what">
                <h4>Product Analyst — Swoo (ADFG Tech India)</h4>
                <p className="where">Bengaluru</p>
                <p className="body">
                  Segmented users with k-means clustering for the marketing team —
                  drove a 30% improvement in customer acquisition. Built automated
                  vertical-wise product-health dashboards and owned the weekly and
                  monthly insight cadence to support data-driven decisions.
                </p>
                <div className="chips">
                  <span className="chip">K-means</span>
                  <span className="chip">Segmentation</span>
                  <span className="chip">Reporting</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer nextHref="/work" nextLabel="Selected work" backHref="/academics" backLabel="Academics" />
    </>
  );
}
