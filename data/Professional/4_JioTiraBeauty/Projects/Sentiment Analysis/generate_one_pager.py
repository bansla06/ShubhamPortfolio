import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyBboxPatch, Rectangle
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import numpy as np

# ── Tira Insights Palette ─────────────────────────────────────────────────────
PAPER      = '#F6F2E9'   # figure background
PAPER2     = '#EFE9DA'   # axes background
PAPER3     = '#E7E0CC'   # default/neutral bars
INK        = '#1A1A1A'   # titles, primary text
INK_SOFT   = '#2A2A2A'   # annotations
MUTED      = '#5A5A5A'   # captions, ticks
SUBTLE     = '#8C8C8C'   # footer
RULE       = (26/255, 26/255, 26/255, 0.14)
RULE_SOFT  = (26/255, 26/255, 26/255, 0.08)

GOLD       = '#A87C30'   # positive · Android highlight
GOLD_DEEP  = '#826021'
GOLD_SOFT  = '#F3EBD8'

BLUSH      = '#8A4F48'   # negative · iOS · risk
BLUSH_SOFT = '#F0E4E3'
BLUSH_LITE = '#B07570'   # lighter blush for secondary

SAGE       = '#4F7259'   # Android platform · healthy
SAGE_SOFT  = '#E3EDE6'

# ── Matplotlib defaults ───────────────────────────────────────────────────────
plt.rcParams.update({
    'font.family':       'DejaVu Sans',
    'text.color':        INK,
    'axes.labelcolor':   MUTED,
    'xtick.color':       MUTED,
    'ytick.color':       MUTED,
    'axes.edgecolor':    MUTED,
    'figure.facecolor':  PAPER,
    'axes.facecolor':    PAPER2,
    'grid.color':        INK,
    'grid.alpha':        0.08,
    'grid.linewidth':    0.6,
})

def style_ax(ax, grid='both'):
    ax.set_facecolor(PAPER2)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color(RULE[:-1] + (0.4,) if isinstance(RULE, tuple) else MUTED)
    ax.spines['bottom'].set_color(MUTED)
    ax.tick_params(colors=MUTED, labelsize=8)
    if grid:
        ax.grid(axis=grid, color=INK, alpha=0.08, linewidth=0.6, zorder=0)

def eyebrow(ax, text):
    """Small gold uppercase label above chart area."""
    ax.annotate(text, xy=(0, 1.10), xycoords='axes fraction',
                fontsize=6.5, color=GOLD, fontweight='bold',
                va='bottom', ha='left', fontfamily='DejaVu Sans')

def chart_title(ax, text):
    ax.annotate(text, xy=(0, 1.04), xycoords='axes fraction',
                fontsize=10.5, fontweight='bold', color=INK,
                va='bottom', ha='left')

# ── Figure & GridSpec ─────────────────────────────────────────────────────────
fig = plt.figure(figsize=(26, 34), facecolor=PAPER)
gs = gridspec.GridSpec(
    7, 3, figure=fig,
    height_ratios=[0.14, 0.18, 1, 1, 1, 1, 0.10],
    hspace=0.60, wspace=0.30,
    left=0.05, right=0.97, top=0.97, bottom=0.02
)

# ══════════════════════════════════════════════════════════════════════════════
# ROW 0 — Masthead
# ══════════════════════════════════════════════════════════════════════════════
ax_mast = fig.add_subplot(gs[0, :])
ax_mast.set_facecolor(PAPER)
ax_mast.axis('off')
# Top rule
ax_mast.plot([0, 1], [1.0, 1.0], color=INK, linewidth=5,
             transform=ax_mast.transAxes, clip_on=False)
ax_mast.plot([0, 1], [0.0, 0.0], color=INK, linewidth=0.8,
             transform=ax_mast.transAxes, clip_on=False)
ax_mast.text(0.5, 0.80, 'TIRA INSIGHTS  ·  PLATFORM REPORT  ·  MAY 2026',
             ha='center', va='center', fontsize=7.5, color=GOLD,
             fontweight='bold', transform=ax_mast.transAxes,
             fontfamily='DejaVu Sans')
ax_mast.text(0.5, 0.44, 'App Reviews — Sentiment Analysis',
             ha='center', va='center', fontsize=24, color=INK,
             fontweight='bold', transform=ax_mast.transAxes,
             fontfamily='DejaVu Serif')
ax_mast.text(0.5, 0.10, '10,435 reviews across Android & iOS  ·  Apr 2023 – May 2026',
             ha='center', va='center', fontsize=10, color=MUTED,
             style='italic', transform=ax_mast.transAxes,
             fontfamily='DejaVu Serif')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 1 — KPI Stat Strip
# ══════════════════════════════════════════════════════════════════════════════
ax_kpi = fig.add_subplot(gs[1, :])
ax_kpi.set_facecolor(PAPER)
ax_kpi.axis('off')
ax_kpi.plot([0,1],[1.0,1.0], color=INK, linewidth=1.2, transform=ax_kpi.transAxes, clip_on=False)
ax_kpi.plot([0,1],[0.0,0.0], color=INK, linewidth=1.2, transform=ax_kpi.transAxes, clip_on=False)

kpis = [
    ('10,435',     'TOTAL REVIEWS',       INK),
    ('3.44 / 5',   'ANDROID AVG RATING',  SAGE),
    ('60.7%',      'ANDROID POSITIVE',    GOLD),
    ('1.94 / 5',   'iOS AVG RATING',      BLUSH),
    ('75.5%',      'iOS NEGATIVE',        BLUSH),
]
cell_w = 1 / len(kpis)
for i, (val, label, color) in enumerate(kpis):
    xc = cell_w * i + cell_w / 2
    if i > 0:
        ax_kpi.plot([cell_w*i, cell_w*i], [0, 1], color=INK, alpha=0.14, linewidth=0.8,
                    transform=ax_kpi.transAxes)
    ax_kpi.text(xc, 0.64, val, ha='center', va='center', fontsize=22,
                fontweight='bold', color=color, transform=ax_kpi.transAxes,
                fontfamily='DejaVu Serif')
    ax_kpi.text(xc, 0.18, label, ha='center', va='center', fontsize=7,
                color=MUTED, fontweight='bold', transform=ax_kpi.transAxes,
                fontfamily='DejaVu Sans')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 2 — Rating dist | Sentiment split | Radar
# ══════════════════════════════════════════════════════════════════════════════

# Chart A — Rating Distribution
ax_a = fig.add_subplot(gs[2, 0]); style_ax(ax_a)
ratings = [1, 2, 3, 4, 5]
and_c = [2871, 288, 356, 908, 4530]; ios_c = [1063, 56, 41, 34, 288]
at, it = sum(and_c), sum(ios_c)
x = np.arange(5); w = 0.38
b1 = ax_a.bar(x - w/2, and_c, width=w, color=SAGE,  label='Android', alpha=0.85, zorder=3)
b2 = ax_a.bar(x + w/2, ios_c, width=w, color=BLUSH, label='iOS',     alpha=0.85, zorder=3)
for bar, cnt, tot, col in [(b1, and_c, at, SAGE), (b2, ios_c, it, BLUSH)]:
    for b, c in zip(bar, cnt):
        ax_a.text(b.get_x()+b.get_width()/2, b.get_height()+30,
                  f'{c/tot*100:.0f}%', ha='center', fontsize=6.5, color=col, fontweight='bold')
ax_a.set_xticks(x); ax_a.set_xticklabels(['★1','★2','★3','★4','★5'], fontsize=9, color=INK)
ax_a.legend(fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
ax_a.set_ylabel('Reviews', fontsize=8, color=MUTED)
eyebrow(ax_a, 'RATING DISTRIBUTION')
chart_title(ax_a, 'Android vs iOS — Star Ratings')

# Chart B — Sentiment Split
ax_b = fig.add_subplot(gs[2, 1]); style_ax(ax_b, grid=None)
platforms = ['Android', 'iOS']
pos_v=[60.7,21.7]; neu_v=[4.0,2.8]; neg_v=[35.3,75.5]
y = np.arange(2); h = 0.45
ax_b.barh(y, pos_v,  height=h, color=GOLD,   label='Positive', alpha=0.9, zorder=3)
ax_b.barh(y, neu_v,  height=h, left=pos_v,   color=PAPER3,     label='Neutral',  alpha=0.9, zorder=3)
ax_b.barh(y, neg_v,  height=h,
          left=[p+n for p,n in zip(pos_v, neu_v)], color=BLUSH, label='Negative', alpha=0.9, zorder=3)
for i, (p, n, ng) in enumerate(zip(pos_v, neu_v, neg_v)):
    if p > 8:  ax_b.text(p/2,        i, f'{p:.0f}%',  ha='center', va='center', fontsize=9, fontweight='bold', color=INK)
    if n > 3:  ax_b.text(p+n/2,      i, f'{n:.0f}%',  ha='center', va='center', fontsize=8, color=MUTED)
    if ng > 8: ax_b.text(p+n+ng/2,   i, f'{ng:.0f}%', ha='center', va='center', fontsize=9, fontweight='bold', color=PAPER)
ax_b.set_yticks(y); ax_b.set_yticklabels(platforms, fontsize=10, fontweight='bold', color=INK)
ax_b.set_xlim(0,100); ax_b.set_xlabel('% of Reviews', fontsize=8)
ax_b.axvline(50, color=MUTED, linestyle='--', linewidth=1, alpha=0.6)
ax_b.legend(fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK,
            framealpha=0.9, loc='lower right')
eyebrow(ax_b, 'SENTIMENT SPLIT')
chart_title(ax_b, 'Positive vs Negative — by Platform')

# Chart C — Radar
ax_c = fig.add_subplot(gs[2, 2], polar=True)
ax_c.set_facecolor(PAPER2)
ax_c.spines['polar'].set_color(MUTED); ax_c.spines['polar'].set_linewidth(0.6)
ax_c.grid(color=INK, alpha=0.10, linewidth=0.6)
ax_c.tick_params(colors=MUTED, labelsize=6.5)
cats = ['Avg\nRating','% Positive','% 5-star','Low\nNegative','Volume\n(norm)','Recency\nScore']
N = len(cats)
angles = np.linspace(0, 2*np.pi, N, endpoint=False).tolist(); angles += angles[:1]
and_s = [0.69,0.61,0.51,0.65,1.0,0.55]; and_s += and_s[:1]
ios_s = [0.39,0.22,0.19,0.25,0.17,0.45]; ios_s += ios_s[:1]
ax_c.plot(angles, and_s, 'o-', lw=2, color=SAGE,  ms=5)
ax_c.fill(angles, and_s, alpha=0.18, color=SAGE)
ax_c.plot(angles, ios_s, 'o-', lw=2, color=BLUSH, ms=5)
ax_c.fill(angles, ios_s, alpha=0.18, color=BLUSH)
ax_c.set_xticks(angles[:-1]); ax_c.set_xticklabels(cats, fontsize=7.5, color=INK)
ax_c.set_ylim(0,1); ax_c.set_yticks([0.25,0.5,0.75,1.0])
ax_c.set_yticklabels(['','','',''], fontsize=0)
and_p = mpatches.Patch(color=SAGE,  label='Android')
ios_p = mpatches.Patch(color=BLUSH, label='iOS')
ax_c.legend(handles=[and_p, ios_p], loc='upper right', bbox_to_anchor=(1.28,1.12),
            fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
ax_c.set_title('PLATFORM HEALTH\nHealth Radar — Android vs iOS',
               fontsize=8, fontweight='bold', color=INK, pad=20, loc='center')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 3 — Pain points | Android version trend | iOS monthly trend
# ══════════════════════════════════════════════════════════════════════════════

# Chart D — Pain Points
ax_d = fig.add_subplot(gs[3, 0]); style_ax(ax_d, grid='x')
th_labels = ['Offers/\nDiscounts','Payment/\nRefund','Delivery/\nShipping',
             'Customer\nSupport','Product\nQuality','Order/\nReturns']
and_neg = [327, 659, 718, 985, 1200, 1692]
ios_neg = [176, 311, 324, 492, 543,  751 ]
y = np.arange(len(th_labels)); h = 0.38
ax_d.barh(y+h/2, and_neg, height=h, color=SAGE,        label='Android', alpha=0.70, zorder=3)
ax_d.barh(y-h/2, ios_neg, height=h, color=BLUSH,       label='iOS',     alpha=0.90, zorder=3)
ax_d.set_yticks(y); ax_d.set_yticklabels(th_labels, fontsize=8, color=INK)
ax_d.set_xlabel('Negative Reviews', fontsize=8, color=MUTED)
ax_d.legend(fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
for bars, vals, col in [(ax_d.patches[:len(th_labels)], and_neg, SAGE),
                        (ax_d.patches[len(th_labels):], ios_neg, BLUSH)]:
    for bar, v in zip(bars, vals):
        ax_d.text(v+8, bar.get_y()+bar.get_height()/2, str(v),
                  va='center', fontsize=7, color=col, fontweight='bold')
eyebrow(ax_d, 'PAIN POINTS  ·  NEGATIVE REVIEWS')
chart_title(ax_d, 'What Frustrates Customers')

# Chart E — Android 5.x Version Trend
ax_e = fig.add_subplot(gs[3, 1]); style_ax(ax_e, grid='y')
versions = ['5.0.0','5.1.1','5.2.1','5.3.1','5.4.0','5.6.0','5.6.1','5.8.1']
avg_r    = [3.26, 3.36, 3.27, 3.42, 3.41, 3.34, 3.21, 3.07]
v_cnt    = [239,  197,  52,   107,  358,  179,  346,  385 ]
x = np.arange(len(versions))
bar_col  = [SAGE if r>=4 else GOLD if r>=3 else BLUSH for r in avg_r]
ax_e.bar(x, v_cnt, color=[c for c in bar_col], alpha=0.5, edgecolor=PAPER3,
         linewidth=0.5, zorder=3)
ax_e2 = ax_e.twinx()
ax_e2.set_facecolor('none')
ax_e2.plot(x, avg_r, 'o-', color=INK, lw=2, ms=6, zorder=5)
for xi, r in zip(x, avg_r):
    ax_e2.text(xi, r+0.06, f'{r:.2f}', ha='center', fontsize=7, color=INK_SOFT)
ax_e2.axhline(3, color=MUTED, linestyle='--', lw=1, alpha=0.6)
ax_e2.set_ylim(0, 5.5); ax_e2.set_ylabel('Avg Rating', fontsize=8, color=MUTED)
ax_e2.tick_params(colors=MUTED, labelsize=7)
ax_e2.spines['top'].set_visible(False)
ax_e2.spines['right'].set_color(MUTED)
ax_e2.spines['left'].set_visible(False)
ax_e2.spines['bottom'].set_visible(False)
ax_e.set_xticks(x); ax_e.set_xticklabels(versions, rotation=35, ha='right', fontsize=7.5)
ax_e.set_ylabel('Review Count', fontsize=8, color=MUTED)
ax_e.annotate('LATEST\n3.07 ↓', xy=(7, v_cnt[7]+10), xytext=(5.5, v_cnt[7]+110),
              fontsize=7.5, color=BLUSH, fontweight='bold',
              arrowprops=dict(arrowstyle='->', color=BLUSH, lw=1.5))
eyebrow(ax_e, 'ANDROID  ·  VERSION TREND')
chart_title(ax_e, '5.x Versions — Rating & Volume')

# Chart F — iOS Monthly Trend
ax_f = fig.add_subplot(gs[3, 2]); style_ax(ax_f, grid='y')
months   = ['Oct\n25','Nov\n25','Dec\n25','Jan\n26','Feb\n26','Mar\n26','Apr\n26','May\n26']
ios_avg  = [2.10, 1.85, 2.38, 2.62, 1.96, 2.18, 2.27, 2.00]
ios_negp = [72,   79,   65,   58,   77,   71,   66,   74  ]
mx = np.arange(len(months))
ax_f.fill_between(mx, ios_avg, color=BLUSH, alpha=0.15)
ax_f.plot(mx, ios_avg, 'o-', color=BLUSH, lw=2.5, ms=7, zorder=5)
for xi, r in zip(mx, ios_avg):
    ax_f.text(xi, r+0.08, f'{r:.2f}', ha='center', fontsize=7.5, color=BLUSH, fontweight='bold')
ax_f.axhline(3, color=MUTED, linestyle='--', lw=1, alpha=0.6)
ax_f.text(7.4, 3.05, 'Neutral\n(3.0)', fontsize=6.5, color=MUTED, va='bottom')
ax_f.set_ylim(0, 4.2); ax_f.set_ylabel('Avg Rating', fontsize=8, color=MUTED)
ax_f2 = ax_f.twinx()
ax_f2.set_facecolor('none')
ax_f2.plot(mx, ios_negp, 's--', color=GOLD_DEEP, lw=1.8, ms=5, alpha=0.85, label='Neg %')
ax_f2.set_ylim(0, 130); ax_f2.set_ylabel('Negative %', fontsize=8, color=GOLD_DEEP)
ax_f2.tick_params(colors=MUTED, labelsize=7)
ax_f2.spines['top'].set_visible(False)
ax_f2.spines['right'].set_color(MUTED)
ax_f2.spines['left'].set_visible(False)
ax_f2.spines['bottom'].set_visible(False)
ax_f.set_xticks(mx); ax_f.set_xticklabels(months, fontsize=8)
blush_line = mpatches.Patch(color=BLUSH,    label='Avg Rating')
gold_line  = mpatches.Patch(color=GOLD_DEEP, label='Negative %')
ax_f.legend(handles=[blush_line, gold_line], fontsize=7.5, facecolor=PAPER,
            edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
eyebrow(ax_f, 'iOS  ·  MONTHLY TREND')
chart_title(ax_f, 'Last 8 Months — Rating & Negative %')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 4 — What customers love | Theme Heatmap
# ══════════════════════════════════════════════════════════════════════════════

# Chart G — What Customers Love
ax_g = fig.add_subplot(gs[4, 0]); style_ax(ax_g, grid='x')
love_th  = ['Delivery/\nShipping','Customer\nSupport','UI / UX',
            'Offers/\nDiscounts','Product\nQuality']
and_pos  = [170, 182, 208, 843, 1019]
ios_pos  = [41,  39,  0,   136, 160 ]
y = np.arange(len(love_th)); h = 0.38
ax_g.barh(y+h/2, and_pos, height=h, color=GOLD,      label='Android', alpha=0.85, zorder=3)
ax_g.barh(y-h/2, ios_pos, height=h, color=SAGE, label='iOS',     alpha=0.85, zorder=3)
ax_g.set_yticks(y); ax_g.set_yticklabels(love_th, fontsize=8, color=INK)
ax_g.set_xlabel('Positive Reviews', fontsize=8, color=MUTED)
ax_g.legend(fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
for bars, vals, col in [(ax_g.patches[:len(love_th)], and_pos, GOLD_DEEP),
                        (ax_g.patches[len(love_th):], ios_pos, SAGE)]:
    for bar, v in zip(bars, vals):
        if v > 0:
            ax_g.text(v+4, bar.get_y()+bar.get_height()/2, str(v),
                      va='center', fontsize=7, color=col, fontweight='bold')
eyebrow(ax_g, 'WHAT CUSTOMERS LOVE  ·  POSITIVE REVIEWS')
chart_title(ax_g, 'Positive Theme Mentions')

# Chart H — Theme Sentiment Heatmap (spans 2 cols)
ax_h = fig.add_subplot(gs[4, 1:]); style_ax(ax_h, grid=None)
hm_rows = ['Order/Returns','Product Quality','Customer Support',
           'Delivery/Shipping','Payment/Refund','App Performance','UI/UX','Offers/Discounts']
hm_data = np.array([
    [53.6,  3.0, 67.1, 14.3],
    [38.0, 18.7, 48.5, 49.7],
    [31.2,  3.3, 44.0, 12.1],
    [22.7,  3.1, 29.0, 12.7],
    [20.9,  2.0, 27.8,  5.0],
    [ 8.0,  1.0, 10.0,  3.0],
    [ 5.0,  3.8,  6.0,  4.0],
    [10.4, 15.5, 15.7, 42.2],
])
col_labels = ['Android\nNeg %', 'Android\nPos %', 'iOS\nNeg %', 'iOS\nPos %']
# Build custom colormaps: Neg = paper2 → blush, Pos = paper2 → gold
neg_cmap  = LinearSegmentedColormap.from_list('neg', [PAPER2, BLUSH])
pos_cmap  = LinearSegmentedColormap.from_list('pos', [PAPER2, GOLD])
neg_cols = [0, 2]; pos_cols = [1, 3]
cell_w_h = 1 / 4; cell_h_h = 1 / 8
for col_i in range(4):
    col_data = hm_data[:, col_i]
    cmap = neg_cmap if col_i in neg_cols else pos_cmap
    norm_d = (col_data - 0) / (col_data.max() + 1e-9)
    for row_i, (val, nd) in enumerate(zip(col_data, norm_d)):
        fc = cmap(nd)
        rect = Rectangle((col_i*cell_w_h, (7-row_i)*cell_h_h),
                          cell_w_h, cell_h_h,
                          transform=ax_h.transAxes,
                          facecolor=fc, edgecolor=PAPER, linewidth=1.5,
                          clip_on=False)
        ax_h.add_patch(rect)
        # Text colour
        txt_col = PAPER if nd > 0.65 else INK
        ax_h.text((col_i+0.5)*cell_w_h, (7-row_i+0.5)*cell_h_h,
                  f'{val:.0f}%',
                  ha='center', va='center', fontsize=9, fontweight='bold',
                  color=txt_col, transform=ax_h.transAxes)
ax_h.set_xlim(0,1); ax_h.set_ylim(0,1)
ax_h.set_xticks([(i+0.5)/4 for i in range(4)])
ax_h.set_xticklabels(col_labels, fontsize=8.5, fontweight='bold', color=INK)
ax_h.set_yticks([(i+0.5)/8 for i in range(8)])
ax_h.set_yticklabels(hm_rows[::-1], fontsize=8.5, color=INK)
ax_h.tick_params(length=0)
ax_h.spines['top'].set_visible(False); ax_h.spines['right'].set_visible(False)
ax_h.spines['left'].set_visible(False); ax_h.spines['bottom'].set_visible(False)
eyebrow(ax_h, 'THEME SENTIMENT HEATMAP')
chart_title(ax_h, '% of Neg / Pos Reviews Mentioning Each Theme')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 5 — Top keywords Neg (dual panel) | Top keywords Pos
# ══════════════════════════════════════════════════════════════════════════════

# Chart I — Negative Keywords (dual panel inside one axes)
ax_i = fig.add_subplot(gs[5, :2]); style_ax(ax_i, grid=None)
neg_w = ['order','product','customer','delivery','service','return','days','experience']
ranks = list(range(8, 0, -1))
y2 = np.arange(8); hw = 0.38
ax_i.barh(y2+hw/2, ranks, height=hw, color=BLUSH_LITE, label='Android', alpha=0.85, zorder=3)
ax_i.barh(y2-hw/2, ranks, height=hw, color=BLUSH,      label='iOS',     alpha=0.90, zorder=3)
ax_i.set_yticks(y2); ax_i.set_yticklabels(neg_w, fontsize=9, color=INK)
ax_i.set_xlabel('Frequency Rank  (higher = more frequent)', fontsize=8, color=MUTED)
ax_i.set_xticks([])
ax_i.legend(fontsize=8, facecolor=PAPER, edgecolor=MUTED, labelcolor=INK, framealpha=0.9)
ax_i.spines['bottom'].set_visible(False)
eyebrow(ax_i, 'TOP KEYWORDS  ·  NEGATIVE REVIEWS')
chart_title(ax_i, 'What Frustrated Customers Wrote')

# Chart J — Positive Keywords
ax_j = fig.add_subplot(gs[5, 2]); style_ax(ax_j, grid=None)
pos_w = ['products','experience','offers','excellent','amazing','discount','shopping','beauty']
pos_ranks = list(range(8, 0, -1))
ax_j.barh(range(8), pos_ranks, color=GOLD, alpha=0.85, zorder=3)
ax_j.set_yticks(range(8)); ax_j.set_yticklabels(pos_w, fontsize=9, color=INK)
ax_j.set_xlabel('Frequency Rank', fontsize=8, color=MUTED)
ax_j.set_xticks([])
ax_j.spines['bottom'].set_visible(False)
eyebrow(ax_j, 'TOP KEYWORDS  ·  POSITIVE REVIEWS')
chart_title(ax_j, 'What Happy Customers Wrote')

# ══════════════════════════════════════════════════════════════════════════════
# ROW 6 — Footer
# ══════════════════════════════════════════════════════════════════════════════
ax_foot = fig.add_subplot(gs[6, :])
ax_foot.set_facecolor(PAPER); ax_foot.axis('off')
ax_foot.plot([0,1],[1.0,1.0], color=INK, linewidth=0.8, transform=ax_foot.transAxes, clip_on=False)
ax_foot.text(0.02, 0.45,
    'Android declining since v5.3.1 → v5.8.1 is worst-rated 5.x version  '
    '|  iOS critical: avg rating 1.94, 75.5% negative',
    ha='left', va='center', fontsize=8.5, color=INK_SOFT, style='italic',
    transform=ax_foot.transAxes, fontfamily='DejaVu Serif')
ax_foot.text(0.98, 0.45,
    'Tira Insights  ·  Sentiment Analysis Pipeline  ·  May 2026',
    ha='right', va='center', fontsize=8, color=SUBTLE, style='italic',
    transform=ax_foot.transAxes, fontfamily='DejaVu Sans')

# ── Save ──────────────────────────────────────────────────────────────────────
plt.savefig('one_pager_insights.png', dpi=150, bbox_inches='tight', facecolor=PAPER)
print('Saved: one_pager_insights.png')
