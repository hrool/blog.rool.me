hugo
find ./public -name '*.html' -exec sed -i 's/https:\/\/disqus\.com/https:\/\/disqus\.rool\.me/g' {} \; 
find ./public -name '*.html' -exec sed -i 's/\.disqus\.com/disqus\.rool\.me/g' {} \;
