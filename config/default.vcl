vcl 4.0;

backend minicron {
  .host = "127.0.0.1";
  .port = "9292";
}

sub vcl_pipe {
  if (req.http.upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
  }
}

sub vcl_recv {
  if (req.http.Upgrade ~ "(?i)websocket") {
    set req.backend_hint = minicron;
    return (pipe);
  } else {
      set req.backend_hint = minicron;
  }
}
