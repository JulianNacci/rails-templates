# Rails Templates

Quickly generate a rails app with the default [Wagon](http://www.lewagon.org) configuration
using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

## Minimal

Get a minimal rails app ready to be deployed on Heroku with Bootstrap, Simple form and
debugging gems.

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/JulianNacci/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
