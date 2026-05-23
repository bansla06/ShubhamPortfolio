export default function ContactFooter({ headline, sub }: { headline: string; sub: string }) {
  return (
    <section id="contact" className="contact">
      <div className="wrap">
        <h2 className="contact__big">
          {headline}<br />
          <em>{sub}</em><br />
          <a href="mailto:Shubhambansla95@gmail.com">Shubhambansla95@gmail.com</a>
        </h2>
        <div className="contact__foot">
          <div>© 2026 Shubham Bansla</div>
          <div>Made with intent, in Gurugram.</div>
        </div>
      </div>
    </section>
  );
}
