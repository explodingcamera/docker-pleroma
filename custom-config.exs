import Config

config :pleroma, :instance,
  registrations_open: false

config :pleroma, Pleroma.Web.Endpoint,
  url: [host: "pleroma.example.org"]

config :pleroma, Pleroma.Web.WebFinger, domain: "example.org"
