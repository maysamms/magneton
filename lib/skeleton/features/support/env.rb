require 'capybara'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require 'rspec'
require 'yaml'
require 'capybara/poltergeist'
require 'fileutils'
require 'i18n'
require_relative 'helper.rb'
require 'imatcher'
require 'chunky_png'
require 'os'
require 'headless'
require 'allure-cucumber'

BROWSER = ENV['BROWSER']
ENVIRONMENT_TYPE = ENV['ENVIRONMENT_TYPE']

## Configure Allure
class Cucumber::Core::Test::Step
  def name
    return text if self.text == 'Before hook'
    return text if self.text == 'After hook'
    "#{source.last.keyword}#{text}"
  end
 end

 AllureCucumber.configure do |c|
  #Generate the XML in the reports directory and not in the allure pattern
  c.output_dir = "reports"
  c.clean_dir  = false
  c.tms_prefix      = '@TMS:'
  c.issue_prefix    = '@ISSUE:'
  c.severity_prefix = '@SEVERITY:'
end 

## register driver according with browser chosen
Capybara.register_driver :selenium do |app|
  if BROWSER.eql?('chrome')
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {
        'args' => ['--window-size=1600,1300']
      }
    )
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: caps)
  elsif BROWSER.eql?('firefox')
    Capybara::Selenium::Driver.new(app, browser: :firefox)
  elsif BROWSER.eql?('internet_explorer')
    Capybara::Selenium::Driver.new(app, browser: :internet_explorer)
  elsif BROWSER.eql?('safari')
    Capybara::Selenium::Driver.new(app, browser: :safari)
  elsif BROWSER.eql?('remote_browser')
    capabilities = Selenium::WebDriver::Remote::Capabilities.send("chrome")
    Capybara::Selenium::Driver.new(
            app, {
              :browser => :remote,
              url: "http://localhost:4444/wd/hub",
              desired_capabilities: capabilities
            }
          )
  elsif BROWSER.eql?('headless_xvfb')
    headless = Headless.new(display: 100)
    headless.start
    Capybara::Selenium::Driver.new(app, :browser => :firefox)
  elsif BROWSER.eql?('poltergeist')
    options = { js_errors: false }
    Capybara::Poltergeist::Driver.new(app, options)
  end
end

IMATCHER = Imatcher::Matcher.new threshold: 0.05
