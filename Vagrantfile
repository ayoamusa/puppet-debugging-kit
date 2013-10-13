# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hammer out a couple of kinks related to Vagrant plugins
if defined? Bundler
  # When running under Bundler, Vagrant disables plugins. We use a Bundler group
  # to simulate the auto-loading that Vagrant normally does when plugins are
  # enabled.
  Bundler.require :vagrant_plugins
else
  require 'vagrant-hosts'
  require 'vagrant-auto_network'
  require 'vagrant-pe_build'
  require 'vagrant-config_builder'
end

# Don't do anything if Oscar is not loaded.
if defined? Oscar
  Vagrant.configure('2') do |config|
    ConfigBuilder::ExtensionHandler.new.load_from_plugins

    # Load the debugging kit configs and then override with any user-specific
    # customizations.
    data = ConfigBuilder::Loader.generate(:yaml, :yamldir, File.expand_path('../config/debugging-kit', __FILE__))
    data.merge! ConfigBuilder::Loader.generate(:yaml, :yamldir, File.expand_path('../config', __FILE__))
    data = ConfigBuilder::FilterStack.new.filter data

    # Generate the model and use it to create Vagrant configuartion
    model = ConfigBuilder::Model.generate data
    model.eval_models config
  end
end