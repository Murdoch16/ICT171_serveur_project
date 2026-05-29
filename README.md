# Stay Aware — Substance Prevention Website

A simple, static, dark-themed prevention website. No animations, no JavaScript,
no build step. Just HTML + one CSS file.

## Files

```
site/
├── index.html              Home / presentation page + the 4 substance cards
├── nicotine.html
├── cannabis.html
├── alcohol.html
├── methamphetamine.html
├── style.css               Shared stylesheet (edit this to restyle everything)
└── images/                 Put your own images here
```

## Adding your own images

On the home page, each card has a placeholder that looks like this:

```html
<div class="thumb">
  <!-- Replace this line with your image:
       <img src="images/nicotine.jpg" alt="Nicotine"> -->
  Image
</div>
```

To add a picture, delete the word `Image` and the comment, then paste your
`<img>` tag, for example:

```html
<div class="thumb">
  <img src="images/nicotine.jpg" alt="Nicotine">
</div>
```

Put the actual image files in the `images/` folder. Square images
(e.g. 600×600) look best since the cards are square.

## Hosting on DigitalOcean

Any of these work — this is just static files:

**Option A — App Platform (easiest)**
1. Push the `site/` folder to a GitHub repo.
2. In DigitalOcean, create a new App → connect the repo.
3. Choose "Static Site". Set the output/source directory to where the
   HTML files are. Deploy.

**Option B — A Droplet with Nginx**
1. Create an Ubuntu Droplet, then `sudo apt update && sudo apt install nginx`.
2. Copy the files: `scp -r site/* root@YOUR_IP:/var/www/html/`
3. Visit your Droplet's IP in a browser.

The fonts load from Google Fonts over the internet. If the server has no
internet access, the site still works but will fall back to a standard
system font.
```
