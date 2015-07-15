initial_host_config:
  local.state.highstate:
    - tgt: '{{ data['id'] }}'
    - kwarg:
        saltenv:
          production
