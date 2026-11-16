 const $ = id =>  document.getElementById(id);
 
  async function  api(path) {

    const res = await fetch(window.API_BASE + path);
    if  (!res.ok) throw new  Error(res.status);
    return res.json();

  }
 
  function el(tag,  cls, text) {

    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text !== undefined) e.textContent = text;
    return e;

  }
 
  const KEYWORDS  = /\b(SELECT|FROM|WHERE|JOIN|LEFT|ON|GROUP BY|ORDER BY|WITH|AS|OVER|PARTITION BY|COUNT|SUM|MAX|CAST|DECIMAL|DISTINCT|TOP|DESC|AND|IS|NULL|RANK|NTILE|LAG|NULLIF|ISNULL|DATEFROMPARTS|YEAR|MONTH)\b/gi;
 
  function  codeBlock(sql) {   
    
// text nodes only, so SQL can never run as HTML
    const pre = el("pre");
    let  last = 0; 
    for (const m of sql.matchAll (KEYWORDS)) {
      pre.append(sql.slice(last, m.index),   el("span", "kw", m[0]));
      last  = m.index + m[0].length;

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
 
  //  Reports
  async function loadReports() {
    const box = $("view-reports");
    try {
      const list =  await api("/api/reports");
      const slots = list.map(r => {
        const card =  el("section", "card");
        const out = el("div", "", "Running query...");

        card.append(el("h2", "", r.title) , el("p", "muted", r.description), codeBlock(r.sql), out);
        box.append(card);

        return { id: r.id, out };
      });

      for
       (const { id, out } of slots)
        {      // one slot at a time to free database it may need a slight timeout session to wake
        try {

          const d = await api("/api/reports/" + id);
          out.replaceChildren(tableEl(d.columns, d.rows));
        } 
        catch (err) {
          out.replaceChildren(el("p", "error", "Could not run this query (" + err.message + "). Refresh in a minute; the free database may be waking up."));
        }
      }

    } catch (err) 
    {
      
      box.append(el("p", "error", "Could not reach the API (" + err.message + ")."));
    }
  }


    // Table browser (server-side search and paging) 
  const state = { table: "Sales", page: 1, search: "", loaded: false };
 
  async function loadTable() {
    try {
      const q = new URLSearchParams({ page: state.page, pageSize: 50, search: state.search });
      const d = await api("/api/tables/" + state.table + "?" + q);
      $("tables-out").replaceChildren(tableEl(d.columns, d.rows));

      const pages = Math.max(1, Math.ceil(d.total / d.pageSize));
      $("info").textContent = d.total.toLocaleString() + " rows - page " + d.page + " of " + pages;
      $("prev").disabled = d.page <= 1;

      $("next").disabled = d.page >= pages;
      $("tables-error").hidden = true;
    } catch (err)
     {

      $("tables-error").textContent = "Could not load data (" + err.message + ").";
      $("tables-error").hidden = false;
    }
  }

 
  async function openTables() {
    if (state.loaded) return;

    state.loaded = true;
    try {

      const names = await api("/api/tables");
      $("table").replaceChildren(...names.map(n => new Option(n, n, false, n === state.table)));
      loadTable();

    } catch (err) {
      $("tables-error").textContent = "Could not reach the API (" + err.message + ").";
      $("tables-error").hidden = false;
    }
  }
 

  $("table").addEventListener("change" , e => { state.table = e.target.value; state.page = 1; loadTable(); });
  $("prev").addEventListener("click", () => { state.page--; loadTable(); });
  $("next").addEventListener ("click", () => { state.page++; loadTable(); });

  let timer;

  $("search").addEventListener("input", e => {

    clearTimeout(timer);
    timer = setTimeout(() => { state.search = e.target.value; state.page = 1; loadTable(); }, 300);
  });
 
  function showTab(name) {

    $("view-reports").hidden =  name !== "reports";
    $("view-tables").hidden = name !== "tables";


    $("tab-reports").classList.toggle("active", name ===  "reports");
    $("tab-tables").classList.toggle("active", name  === "tables");
    if (name === "tables") openTables();

  }
  $("tab-reports").addEventListener("click", () =>  showTab("reports"));
  $("tab-tables").addEventListener("click", () =>  showTab("tables"));
 

  loadReports();