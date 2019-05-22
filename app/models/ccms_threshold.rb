class CcmsThreshold < YamlStore
  use_yml_file Rails.root.join('config/thresholds.yml'), section: :ccms
end
