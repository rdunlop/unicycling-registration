{
  "name": "unicycling-registration",
  "private": true,
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@nathanvda/cocoon": "^1.2.14",
    "@rails/actiontext": "^7.1.0",
    "@rails/activestorage": "^7.1.0",
    "@rails/ujs": "^7.1.0",
    "datatables.net": "^1.13.8",
    "datatables.net-zf": "^1.13.8",
    "esbuild": "^0.20.1",
    "foundation-sites": "^6.8.1",
    "jquery": "^3.7.1",
    "jquery-datetimepicker": "^2.5.20",
    "jquery-ui-dist": "^1.13.2",
    "select2": "^4.1.0-rc.0",
    "trix": "^2.1.1"
  },
  "scripts": {
    "build": "esbuild app/javascript/application.js --bundle --sourcemap --outdir=app/assets/builds --public-path=/assets",
    "build:css": "sass ./app/assets/stylesheets/base_green_blue.scss:./app/assets/builds/base_green_blue.css ./app/assets/stylesheets/base_blue_pink.scss:./app/assets/builds/base_blue_pink.css ./app/assets/stylesheets/base_blue_purple.scss:./app/assets/builds/base_blue_purple.css ./app/assets/stylesheets/base_purple_blue.scss:./app/assets/builds/base_purple_blue.css ./app/assets/stylesheets/pdf.scss:./app/assets/builds/pdf.css --no-source-map --load-path=node_modules"
  }
}
