const $ = id => document.getElementById(id);

//  API
const cache = {};                                   // each report runs once per page load
async function api(path) {
  const res = await fetch(window.API_BASE + path);
  if (!res.ok) throw new Error(res.status + " - " + (await res.text()).slice(0, 400));
  return res.json();
}
const report = id => (cache[id] ??= api("/api/reports/" + id));

// Reports are loaded from the Reports SQL file 

const R = {
  branch:    "01-revenue-by-branch",
  trend:     "02-monthly-revenue-trend",
  products:  "03-top-products-per-category",
  customers: "04-top-customers",
  staff:     "05-employee-ranking",
  inactive:  "06-customers-without-purchases",
};

// -- helpers

function el(tag, cls, text) {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (text !== undefined) e.textContent = text;
  return e;
}

const NS = "http://www.w3.org/2000/svg";
function svgEl(tag, attrs, text) {

  const e = document.createElementNS(NS, tag);
  for (const k in attrs) e.setAttribute(k, attrs[k]);
  if (text !== undefined) e.textContent = text;
  return e;
}

// { columns, rows } from the API becomes a list of objects
function toObjects(d) 
{
  return d.rows.map(r => Object.fromEntries(d.columns.map((c, i) => [c, r[i]])));
}

const trim = n => n.toFixed(1).replace(/\.0$/, "");
const money = v => "R " + v.toLocaleString("en-ZA", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const moneyShort = v => {
  const a = Math.abs(v);
  if (a >= 1e6) return "R " + trim(v / 1e6) + "M";
  if (a >= 1e3) return "R " + trim(v / 1e3) + "k";
  return "R " + Math.round(v);
};
const count = v => Math.round(v).toLocaleString("en-ZA");
const sum = (rows, key) => rows.reduce((t, r) => t + (r[key] ?? 0), 0);
const COLORS = ["var(--amber)", "var(--violet)", "var(--lime)", "var(--coral)"];

function initials(name) {
  return name.split(/\s+/).filter(Boolean).slice(0, 2).map(w => w[0].toUpperCase()).join("");
}

function monthLabel(iso, long, withYear) {
  const d = new Date(iso + "T00:00:00");
  return d.toLocaleDateString("en-ZA", long
    ? { month: "long", year: "numeric" }
    : withYear ? { month: "short", year: "2-digit" } : { month: "short" });
}

//  widgets
// Runs a report into a container. Resolves true if it worked, false if not.

function widget(promise, target, render) {
  return promise.then(d => {
    const rows = toObjects(d);
    target.replaceChildren();
    if (!rows.length) { target.append(note(target, "No data yet.")); return true; }
    render(rows, target);
    return true;
  }).catch(err => {
    target.replaceChildren(note(target, "Could not load this data (" + err.message + ").", true));
    return false;
  });
}


function note(target, text, isError) {
  const cls = isError ? "error" : "empty";
  return el(target.tagName === "OL" ? "li" : "p", cls, text);
}

function listItem(index, name, meta, value) {
  const li = el("li");
  const av = el("span", "avatar", initials(name));
  av.style.background = COLORS[index % COLORS.length];
  const mid = el("div");
  mid.append(el("div", "who", name), el("div", "meta", meta));
  li.append(av, mid, el("span", "val", value));
  return li;
}

// KPI cards
function setKpi(id, value, text) {
  $(id).textContent = value;
  $(id + "-note").textContent = text || " ";
}

function loadKpis() {
  const branchKpis = report(R.branch).then(d => {
    const rows = toObjects(d);
    const revenue = sum(rows, "Revenue"), profit = sum(rows, "Profit"), sales = sum(rows, "Sales");
    setKpi("k-revenue", money(revenue), rows.length + " branches");
    setKpi("k-profit", money(profit), revenue ? trim(100 * profit / revenue) + "% margin" : "");
    setKpi("k-sales", count(sales), sales ? "Average sale " + money(revenue / sales) : "");
    return true;
  }).catch(() => {
    for (const id of ["k-revenue", "k-profit", "k-sales"]) setKpi(id, "-", "Not available");
    return false;
  });

  const customerKpi = api("/api/tables/Customer?pageSize=1").then(async d => {
    let text = "";
    try {
      const n = (await report(R.inactive)).rows.length;
      text = n === 0 ? "All have bought" : (n >= 50 ? "50+" : n) + " have not bought yet";
    } catch { /* the note is optional */ }
    setKpi("k-customers", count(d.total), text);
    return true;
  }).catch(() => { setKpi("k-customers", "-", "Not available"); return false; });

  return Promise.all([branchKpis, customerKpi]);
}

//  Revenue trend chart (hand-drawn SVG, no libraries)
const trend = { rows: [], mode: "Revenue" };

function niceMax(v) {

  if (v <= 0) return 1;
  const p = Math.pow(10, Math.floor(Math.log10(v)));
  const n = v / p;
  return (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * p;   // five even steps: 1, 2, 5 or 10 times a power of ten
}

function drawTrend(animate) {
  const host = $("trend");
  const rows = trend.rows;


  if (!rows.length) return;

  const key = trend.mode;
  const W = host.clientWidth || 640, H = host.clientHeight || 290;
  const m = { t: 14, r: 14, b: 30, l: 58 };
  const iw = W - m.l - m.r, ih = H - m.t - m.b;
  const max = niceMax(Math.max(...rows.map(r => r[key])));
  const x = i => rows.length === 1 ? m.l + iw / 2 : m.l + i * iw / (rows.length - 1);
  const y = v => m.t + ih - (v / max) * ih;

  const svg = svgEl("svg", { viewBox: `0 0 ${W} ${H}`, role: "img",
    "aria-label": "Chart of revenue by month. " + $("trend-sub").textContent });
  if (!animate) svg.classList.add("static");

  const defs = svgEl("defs", {});
  const grad = svgEl("linearGradient", { id: "areaFill", x1: 0, y1: 0, x2: 0, y2: 1 });
  grad.append(svgEl("stop", { offset: "0%", "stop-color": "#f6b94f", "stop-opacity": ".32" }),
              svgEl("stop", { offset: "100%", "stop-color": "#f6b94f", "stop-opacity": "0" }));
  defs.append(grad);
  svg.append(defs);

  for (let i = 0; i <= 5; i++) {                          // grid lines and money labels
    const v = max * i / 5, yy = y(v);
    svg.append(svgEl("line", { class: "grid", x1: m.l, x2: W - m.r, y1: yy, y2: yy }),
               svgEl("text", { class: "axis", x: m.l - 10, y: yy, dy: ".32em", "text-anchor": "end" }, moneyShort(v)));
  }

  const spanYears = new Set(rows.map(r => r.Month_Start.slice(0, 4))).size > 1;
  const step = Math.max(1, Math.ceil(rows.length / Math.max(1, Math.floor(iw / 64))));
  rows.forEach((r, i) => {
    if (i % step === 0) svg.append(svgEl("text", { class: "axis", x: x(i), y: H - 8, "text-anchor": "middle" },
      monthLabel(r.Month_Start, false, spanYears)));
  });

  // smooth line that never dips below the data (horizontal bezier handles)
  let d = `M${x(0)},${y(rows[0][key])}`;
  for (let i = 1; i < rows.length; i++) {
    const mx = (x(i - 1) + x(i)) / 2;
    d += ` C${mx},${y(rows[i - 1][key])} ${mx},${y(rows[i][key])} ${x(i)},${y(rows[i][key])}`;
  }
  svg.append(svgEl("path", { class: "area", d: `${d} L${x(rows.length - 1)},${y(0)} L${x(0)},${y(0)} Z` }),
             svgEl("path", { class: "line", d, pathLength: 1 }));

  // hover: guide line, dot and tooltip
  const guide = svgEl("line", { class: "guide", y1: m.t, y2: m.t + ih, visibility: "hidden" });
  const dot = svgEl("circle", { class: "pt", r: 5, visibility: "hidden" });
  const hit = svgEl("rect", { x: m.l, y: m.t, width: iw, height: ih, fill: "transparent" });
  svg.append(guide, dot, hit);

  const tip = el("div", "tip"); tip.hidden = true;
  const show = ev => {
    const box = svg.getBoundingClientRect();
    const px = ev.clientX - box.left;
    const i = Math.max(0, Math.min(rows.length - 1, Math.round((px - m.l) / (iw / Math.max(1, rows.length - 1)))));
    const r = rows[i], cx = x(i), cy = y(r[key]);
    guide.setAttribute("x1", cx); guide.setAttribute("x2", cx);
    dot.setAttribute("cx", cx); dot.setAttribute("cy", cy);
    guide.setAttribute("visibility", "visible"); dot.setAttribute("visibility", "visible");
    tip.replaceChildren(monthLabel(r.Month_Start, true), el("small", "", money(r[key])));
    if (trend.mode === "Revenue" && r.Growth_Pct !== null && r.Growth_Pct !== undefined)
      tip.firstElementChild.append(document.createElement("br"), (r.Growth_Pct >= 0 ? "+" : "") + r.Growth_Pct + "% on the month before");
    tip.hidden = false;
    tip.style.left = Math.max(70, Math.min(W - 70, cx)) + "px";
    tip.style.top = Math.max(cy - 12, 52) + "px";
  };
  const hide = () => { guide.setAttribute("visibility", "hidden"); dot.setAttribute("visibility", "hidden"); tip.hidden = true; };
  hit.addEventListener("pointermove", show);
  hit.addEventListener("pointerdown", show);
  hit.addEventListener("pointerleave", hide);

  host.replaceChildren(svg, tip);
}

function loadTrend() {
  const host = $("trend");
  return report(R.trend).then(d => {
    trend.rows = toObjects(d);
    if (!trend.rows.length) { host.replaceChildren(el("p", "empty", "No sales yet.")); return true; }
    const best = trend.rows.reduce((a, b) => (b.Revenue > a.Revenue ? b : a));
    const last = trend.rows[trend.rows.length - 1];
    let text = "Best month was " + monthLabel(best.Month_Start, true) + " at " + moneyShort(best.Revenue) + ".";
    if (last.Growth_Pct !== null && last.Growth_Pct !== undefined)
      text += " The latest month is " + (last.Growth_Pct >= 0 ? "up " : "down ") + Math.abs(last.Growth_Pct) + "% on the month before.";
    $("trend-sub").textContent = text;
    drawTrend(true);
    return true;
  }).catch(err => {
    host.replaceChildren(el("p", "error", "Could not load this data (" + err.message + ")."));
    return false;
  });
}

function setTrendMode(key) {
  trend.mode = key;
  $("seg-monthly").classList.toggle("active", key === "Revenue");
  $("seg-running").classList.toggle("active", key === "Running_Total");
  $("seg-monthly").setAttribute("aria-pressed", key === "Revenue");
  $("seg-running").setAttribute("aria-pressed", key === "Running_Total");
  drawTrend(true);
}
$("seg-monthly").addEventListener("click", () => setTrendMode("Revenue"));
$("seg-running").addEventListener("click", () => setTrendMode("Running_Total"));

let resizeTimer;
window.addEventListener("resize", () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => drawTrend(false), 120);
});

// ---- Branch bars
function renderBranches(rows, box) {
  const max = Math.max(...rows.map(r => r.Revenue), 1);
  const wrap = el("div", "bars");
  rows.forEach(r => {
    const row = el("div", "bar-row");
    const top = el("div", "bar-row-top");
    top.append(el("span", "", r.Branch_Name), el("span", "", money(r.Revenue)));
    const track = el("div", "track"), fill = el("div", "fill");
    fill.style.width = (100 * r.Revenue / max) + "%";
    track.append(fill);
    row.append(top, track, el("div", "bar-meta",
      count(r.Sales) + " sales, " + (r.Margin_Pct ?? 0) + "% margin, " + money(r.Profit) + " profit"));
    wrap.append(row);
  });
  box.append(wrap);
}

// ---- Best product per category
function renderCategories(rows, box) {
  const wrap = el("div", "rows");
  rows.filter(r => r.Rank_In_Category === 1).forEach(r => {
    const row = el("div", "row");
    row.append(el("div", "what", r.Product_Name),
               el("div", "where", r.Category_name + ", " + count(r.Units_Sold) + " units sold"),
               el("div", "amt", money(r.Profit)));
    wrap.append(row);
  });
  box.append(wrap);
}

// ---- Side lists
function renderCustomers(rows, ol) {
  rows.slice(0, 6).forEach((r, i) =>
    ol.append(listItem(i, r.Customer, r.City + ", " + r.Orders + (r.Orders === 1 ? " order" : " orders"), money(r.Total_Spent))));
}

function renderStaff(rows, ol) {
  const seen = new Set();
  rows.forEach(r => {                                  // the report is sorted by rank, so the first row per branch is the best
    if (seen.has(r.Branch_Name) || r.Rank_In_Branch !== 1) return;
    seen.add(r.Branch_Name);
    ol.append(listItem(seen.size - 1, r.Full_Name, r.Branch_Name + ", " + r.Job_Title, moneyShort(r.Revenue)));
  });
}

function renderInactive(rows, ol) {
  rows.slice(0, 6).forEach((r, i) =>
    ol.append(listItem(i, r.First_Name + " " + r.Last_Name, r.City, "Joined " + r.Joined_Date)));
}

// ---- Overview

async function loadOverview() {
  const results = await Promise.all([
    loadKpis(),
    loadTrend(),
    widget(report(R.branch), $("branches"), renderBranches),
    widget(report(R.products), $("categories"), renderCategories),
    widget(report(R.customers), $("customers"), renderCustomers),
    widget(report(R.staff), $("staff"), renderStaff),
    widget(report(R.inactive), $("inactive"), (rows, ol) => renderInactive(rows, ol)),
  ]);

  const flags = results.flat();
  const status = $("api-status");
  const ok = flags.filter(Boolean).length;
  status.className = "api-status " + (ok === flags.length ? "ok" : "bad");
  $("api-status-text").textContent = ok === flags.length ? "API connected" //Display a message on the bottom left if the API is connected successfully 
    : ok === 0 ? "API not reachable" : "Some data failed to load";
}

// ---------------------------------------------------------------- SQL reports view
const KEYWORDS = /\b(SELECT|FROM|WHERE|JOIN|LEFT|ON|GROUP BY|ORDER BY|WITH|AS|OVER|PARTITION BY|COUNT|SUM|MAX|CAST|DECIMAL|DISTINCT|TOP|DESC|AND|IS|NULL|RANK|NTILE|LAG|NULLIF|ISNULL|DATEFROMPARTS|YEAR|MONTH)\b/gi;


function codeBlock(sql) {              // text nodes only, so SQL can never run as HTML
  const pre = el("pre");
  let last = 0;
  for (const m of sql.matchAll(KEYWORDS)) {
    pre.append(sql.slice(last, m.index), el("span", "kw", m[0]));
    last = m.index + m[0].length;
  }
  pre.append(sql.slice(last));
  return pre;
}


function fmt(v, col) {
  if (v === null) return "";
  if (typeof v === "number" && /Price|Amount|Revenue|Profit|Spent|Order|Total/.test(col) && !/Orders/.test(col)) {
    return v.toLocaleString("en-ZA", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  return v;
}

function tableEl(columns, rows) {
  const table = el("table");
  const head = el("tr");
  columns.forEach(c => head.append(el("th", "", c)));
  const thead = el("thead"); thead.append(head);
  const tbody = el("tbody");
  rows.forEach(row => {
    const tr = el("tr");
    row.forEach((v, i) => tr.append(el("td", typeof v === "number" ? "num" : "", fmt(v, columns[i]))));
    tbody.append(tr);
  });
  table.append(thead, tbody);
  const wrap = el("div", "wrap"); wrap.append(table);
  return wrap;
}

async function loadReports() {
  const box = $("view-reports");
  try {
    const list = await api("/api/reports");
    for (const r of list) {
      const card = el("section", "card");
      const out = el("div", "", "Running query...");
      const code = codeBlock(r.sql);
      code.hidden = true;                  // SQL stays hidden until the user asks for it
      const toggle = el("button", "sql-toggle", "View SQL");
      toggle.addEventListener("click", () => {
        code.hidden = !code.hidden;
        toggle.textContent = code.hidden ? "View SQL" : "Hide SQL";
      });
      card.append(el("h2", "", r.title), r.description ? el("p", "muted", r.description) : "", out, toggle, code);
      box.append(card);
      report(r.id)
        .then(d => out.replaceChildren(tableEl(d.columns, d.rows)))
        .catch(err => out.replaceChildren(el("p", "error", "Could not run this query (" + err.message + ")")));
    }
  } catch (err) {
    box.append(el("p", "error", "Could not reach the API (" + err.message + ")."));
  }
}

// ---------------------------------------------------------------- Table browser (server-side search and paging)
const state = { table: "Sales", page: 1, search: "" };

async function loadTable() {
  try {
    const q = new URLSearchParams({ page: state.page, pageSize: 50, search: state.search });
    const d = await api("/api/tables/" + state.table + "?" + q);
    $("tables-out").replaceChildren(tableEl(d.columns, d.rows));
    const pages = Math.max(1, Math.ceil(d.total / d.pageSize));
    $("info").textContent = d.total.toLocaleString() + " rows, page " + d.page + " of " + pages;
    $("prev").disabled = d.page <= 1;
    $("next").disabled = d.page >= pages;
    $("tables-error").hidden = true;
  } catch (err) {
    $("tables-error").textContent = "Could not load data (" + err.message + ").";
    $("tables-error").hidden = false;
  }
}

async function openTables() {
  try {
    const names = await api("/api/tables");
    $("table").replaceChildren(...names.map(n => new Option(n, n, false, n === state.table)));
    loadTable();
  } catch (err) {
    $("tables-error").textContent = "Could not reach the API (" + err.message + ").";
    $("tables-error").hidden = false;
  }
}

$("table").addEventListener("change", e => { state.table = e.target.value; state.page = 1; loadTable(); });
$("prev").addEventListener("click", () => { state.page--; loadTable(); });
$("next").addEventListener("click", () => { state.page++; loadTable(); });
let searchTimer;
$("search").addEventListener("input", e => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => { state.search = e.target.value; state.page = 1; loadTable(); }, 300);
});

//Navigation
const VIEWS = {
  overview: { title: "Sales overview", sub: "Every figure on this page is read live from the SQL data warehouse.", load: loadOverview },
  reports:  { title: "SQL reports", sub: "The queries behind the dashboard. Select View SQL to read one.", load: loadReports },
  tables:   { title: "Browse tables", sub: "Search and page through the raw warehouse tables.", load: openTables },
};



const loaded = {};

function showView(name) {

  if (!VIEWS[name]) name = "overview";
  for (const v in VIEWS) {
    $("view-" + v).hidden = v !== name;
    $("tab-" + v).classList.toggle("active", v === name);

    if 
    
    (v === name) $("tab-" + v).setAttribute("aria-current", "page");
    else $("tab-" + v).removeAttribute("aria-current");
  }


  $("page-title").textContent = VIEWS[name].title;
  $("page-sub").textContent = VIEWS[name].sub;
  history.replaceState(null, "", "#" + name);
  if
   (!loaded[name]) { loaded[name] = true; VIEWS[name].load();

    }
  if
   (name === "overview") drawTrend(false);        // the chart needs a visible box to measure
}

for (const v in VIEWS) $("tab-" + v).addEventListener("click", () => showView(v));
$("refresh").addEventListener("click", () => location.reload());

showView(location.hash.slice(1));