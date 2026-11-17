window.API_BASE = new URLSearchParams(location.search).has("local")
  ? "http://localhost:5014"
  : "https://smallretail-api-c6dmgxcpg2g8aydc.southafricanorth-01.azurewebsites.net";