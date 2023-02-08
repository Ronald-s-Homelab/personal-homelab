variable "name" {
  type = string
}

variable "region" {
  type = string
}

# variable "invite_ch_id" {
#   type = number
# }

variable "members" {
  type = map(object({
    teams = list(string)
  }))
}

variable "categories" {
  type    = list(string)
  default = []
}

variable "roles" {
  type = map(object({
    config = object({
      hoist       = bool
      mentionable = bool
      position    = number
    })
    discord_perms = object({
      add_reactions             = optional(string, "unset")
      add_reactions             = optional(string, "unset")
      administrator             = optional(string, "unset")
      attach_files              = optional(string, "unset")
      change_nickname           = optional(string, "unset")
      connect                   = optional(string, "unset")
      create_instant_invite     = optional(string, "unset")
      create_private_threads    = optional(string, "unset")
      create_public_threads     = optional(string, "unset")
      create_public_threads     = optional(string, "unset")
      deafen_members            = optional(string, "unset")
      embed_links               = optional(string, "unset")
      manage_channels           = optional(string, "unset")
      manage_emojis             = optional(string, "unset")
      manage_events             = optional(string, "unset")
      manage_guild              = optional(string, "unset")
      manage_messages           = optional(string, "unset")
      manage_nicknames          = optional(string, "unset")
      manage_roles              = optional(string, "unset")
      manage_threads            = optional(string, "unset")
      manage_webhooks           = optional(string, "unset")
      moderate_members          = optional(string, "unset")
      move_members              = optional(string, "unset")
      mute_members              = optional(string, "unset")
      read_message_history      = optional(string, "unset")
      send_messages             = optional(string, "unset")
      send_messages             = optional(string, "unset")
      send_messages             = optional(string, "unset")
      send_thread_messages      = optional(string, "unset")
      send_thread_messages      = optional(string, "unset")
      speak                     = optional(string, "unset")
      start_embedded_activities = optional(string, "unset")
      stream                    = optional(string, "unset")
      use_application_commands  = optional(string, "unset")
      use_external_emojis       = optional(string, "unset")
      use_external_stickers     = optional(string, "unset")
      use_vad                   = optional(string, "unset")
      view_audit_log            = optional(string, "unset")
      view_channel              = optional(string, "unset")
      view_channel              = optional(string, "unset")
      view_guild_insights       = optional(string, "unset")
    })
  }))
}
