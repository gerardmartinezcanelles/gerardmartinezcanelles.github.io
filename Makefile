commit:
	git add .
	git commit -m "Update site content"
	git push

deploy:
	uv run mkdocs gh-deploy --force

serve:
	uv run mkdocs serve	

all: commit deploy
