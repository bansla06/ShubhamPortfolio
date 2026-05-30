"use client";
import Nav from "../components/Nav";
import Footer from "../components/Footer";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function Academics() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <header className="page-head">
        <div className="wrap page-head__inner reveal">
          <div>
            <div className="crumb"><span />02 · Academics</div>
            <h1>Where I<br /><em>learned to think.</em></h1>
          </div>
          <p className="lede">
            A mechanical-engineering start, an MBA, and then two specialised
            programmes that pulled me firmly into data science and statistics.
          </p>
        </div>
      </header>

      <main className="page-body">
        <div className="wrap">
          <div className="timeline">
            <div className="tl-row reveal">
              <div className="when">2021 – 2022</div>
              <div className="mark" />
              <div className="what">
                <h4>Post Graduate Diploma in Applied Statistics</h4>
                <p className="where">Indira Gandhi National Open University (IGNOU)</p>
                <p className="body">
                  Formal grounding in inferential statistics, regression and
                  experimental design — the layer beneath every dashboard I build.
                </p>
                <div className="chips">
                  <span className="chip">Statistics</span>
                  <span className="chip">Regression</span>
                  <span className="chip">Experimental design</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2018 – 2019</div>
              <div className="mark" />
              <div className="what">
                <h4>Post Graduate Program in Data Science</h4>
                <p className="where">Praxis Business School, Bengaluru</p>
                <p className="body">
                  Industry-focused programme covering Python, SQL, machine learning
                  and visualisation. The pivot point that turned my MBA-and-engineering
                  background into a product analytics career.
                </p>
                <div className="chips">
                  <span className="chip">Python</span>
                  <span className="chip">SQL</span>
                  <span className="chip">Machine learning</span>
                </div>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2016 – 2018</div>
              <div className="mark" />
              <div className="what">
                <h4>MBA, Marketing &amp; Operations</h4>
                <p className="where">Dr. A.P.J. Abdul Kalam Technical University, Uttar Pradesh</p>
                <p className="body">
                  Where I picked up the language of business — marketing funnels,
                  operations, P&amp;L thinking — that I now pair with the data side every day.
                </p>
              </div>
            </div>
            <div className="tl-row reveal">
              <div className="when">2012 – 2016</div>
              <div className="mark" />
              <div className="what">
                <h4>B.Tech, Mechanical Engineering</h4>
                <p className="where">Dr. A.P.J. Abdul Kalam Technical University, Uttar Pradesh</p>
                <p className="body">
                  Four years of first-principles thinking. Looking back, the habit of
                  breaking a system down into its parts is the thing I carry forward most.
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer nextHref="/experience" nextLabel="Experience" backHref="/about" backLabel="About" />
    </>
  );
}
