import Link from "next/link";

export default function Footer({
  nextHref,
  nextLabel,
  backHref,
  backLabel,
}: {
  nextHref: string;
  nextLabel: string;
  backHref: string;
  backLabel: string;
}) {
  return (
    <footer className="site-foot">
      <div className="wrap foot-next">
        <div>
          <div className="label">Next</div>
          <Link href={nextHref} className="big">
            {nextLabel} <span className="arrow">→</span>
          </Link>
        </div>
        <Link href={backHref} className="case__back">
          ← {backLabel}
        </Link>
      </div>
      <div className="wrap foot-bar">
        <div>© 2026 Shubham Bansla</div>
        <div className="links">
          <a href="mailto:Shubhambansla95@gmail.com">Email</a>
          <a href="https://www.linkedin.com/in/shubham-bansla/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
        </div>
        <div>Gurugram, IN</div>
      </div>
    </footer>
  );
}
