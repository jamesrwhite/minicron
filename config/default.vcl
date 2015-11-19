vcl 4.0;

backend minicron {
  .host = "127.0.0.1";
  .port = "9292";
}

sub vcl_recv {
    set req.backend_hint = minicron;
}
