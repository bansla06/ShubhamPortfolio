"use client";
import Nav from "../components/Nav";
import { useScrollReveal } from "../hooks/useScrollReveal";

export default function Contact() {
  useScrollReveal();
  return (
    <>
      <Nav />
      <section id="contact" className="contact" style={{ minHeight: "calc(100vh - 64px)", display: "flex", flexDirection: "column", justifyContent: "center" }}>
        <div className="wrap">
          <div className="crumb" style={{ fontSize: "var(--fs-12)", letterSpacing: "var(--tracking-caps)", textTransform: "uppercase", color: "var(--coral-200)", display: "flex", gap: "12px", alignItems: "center", marginBottom: "28px" }}>
            <span style={{ display: "inline-block", width: "24px", height: "1px", background: "var(--coral-400)" }} />
            06 · Contact
          </div>
          <h2 className="contact__big reveal">
            Have a tricky<br />
            question to <em>untangle?</em><br />
            <a href="mailto:Shubhambansla95@gmail.com">Shubhambansla95@gmail.com</a>
          </h2>
          <div className="contact__grid reveal-stagger">
            <a href="mailto:Shubhambansla95@gmail.com">
              <span className="k">Email</span>
              <span className="v">Shubhambansla95@gmail.com</span>
            </a>
            <a href="tel:+919958852491">
              <span className="k">Phone</span>
              <span className="v">+91 99588 52491</span>
            </a>
            <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer">
              <span className="k">LinkedIn</span>
              <span className="v">in/shubham-bansla</span>
            </a>
            <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer">
              <span className="k">Writing</span>
              <span className="v">Medium · CTV essay</span>
            </a>
          </div>
          <div className="contact__foot">
            <div>© 2026 Shubham Bansla</div>
            <div>Made with intent, in Gurugram.</div>
          </div>
        </div>
      </section>
    </>
  );
}
