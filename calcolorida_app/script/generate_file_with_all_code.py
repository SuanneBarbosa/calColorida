import os
from pathlib import Path
import gitignore_parser

def consolidate_flutter_project(project_dir, output_file):
    gitignore_path = os.path.join(project_dir, ".gitignore")
    matches_gitignore = gitignore_parser.parse_gitignore(gitignore_path) if os.path.exists(gitignore_path) else None

    with open(output_file, "w", encoding="utf-8") as outfile:
        for root, _, files in os.walk(project_dir):
            for file in files:
                if file.endswith(".dart"):
                    file_path = os.path.join(root, file)
                    relative_path = Path(file_path).relative_to(project_dir)
                    if matches_gitignore and matches_gitignore(relative_path):
                        continue  # Ignora arquivos listados no .gitignore
                    with open(file_path, "r", encoding="utf-8") as infile:
                        content = infile.read()
                        outfile.write(f"[{relative_path}]\n\n")
                        outfile.write(content)
                        outfile.write("\n----------------\n")

if __name__ == "__main__":
    project_directory = "C:\\Users\\suann\\projetos-flutter\\calColorida\\calcolorida_app\\lib"
    output_file_name = "codigo_consolidado.txt"
    consolidate_flutter_project(project_directory, output_file_name)


