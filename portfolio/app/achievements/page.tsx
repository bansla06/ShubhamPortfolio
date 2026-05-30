"use client";
import Nav from "../components/Nav";
import Footer from "../components/Footer";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function Achievements() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <header className="page-head">
        <div className="wrap page-head__inner reveal">
          <div>
            <div className="crumb"><span />05 · Recognition</div>
            <h1>A few moments<br /><em>worth marking.</em></h1>
          </div>
          <p className="lede">
            Certifications I&apos;ve earned, work I&apos;m quietly proud of, and the blog post I
            still occasionally re-read.
          </p>
        </div>
      </header>

      <main className="page-body">
        <div className="wrap">
          <div className="achievements">
            <div className="ach reveal">
              <div className="yr">2024</div>
              <div className="txt">
                <h4>10% lift in Treats engagement at Tira</h4>
                <p>A/B test on the user loyalty journey, partnered with UX/UI.</p>
              </div>
            </div>
            <div className="ach reveal">
              <div className="yr">2023</div>
              <div className="txt">
                <h4>PLP bounce rate down 7–10%</h4>
                <p>Built and shipped a new relevancy algorithm for Tira product listing pages.</p>
              </div>
            </div>
            <div className="ach reveal">
              <div className="yr">2022</div>
              <div className="txt">
                <h4>Fraud detection at Threedots</h4>
                <p>Cut daily incentive outflow by 15% through behavioural pattern detection.</p>
              </div>
            </div>
            <div className="ach reveal">
              <div className="yr">2021</div>
              <div className="txt">
                <h4>$5M business contribution at MiQ</h4>
                <p>Built the automated post-campaign OTT insights dashboard ecosystem.</p>
              </div>
            </div>
            <div className="ach reveal">
              <div className="yr">—</div>
              <div className="txt">
                <h4>Published on Medium — &ldquo;Connected TV: A disruption in digital advertising&rdquo;</h4>
                <p>An essay on attribution, measurement and creative in the CTV era.</p>
              </div>
            </div>
            <div className="ach reveal">
              <div className="yr">—</div>
              <div className="txt">
                <h4>Certifications</h4>
                <p>Coursera — &ldquo;Exploring &amp; preparing your data with BigQuery&rdquo; (E2NEQKMGAYB3). Google — Campaign Manager (49259709), Display &amp; Video 360.</p>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer nextHref="/contact" nextLabel="Get in touch" backHref="/work" backLabel="Work" />
    </>
  );
}
