import os

def collect_dart_files(source_dirs, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for source_dir in source_dirs:
            for root, _, files in os.walk(source_dir):
                for file in files:
                    if file.endswith('.dart'):
                        file_path = os.path.join(root, file)
                        with open(file_path, 'r', encoding='utf-8') as dart_file:
                            outfile.write(f"\n\n// === File: {file_path} ===\n")
                            outfile.write(dart_file.read())
                            outfile.write("\n")

# 📁 Update these paths according to your actual project root
source_directories = [
    './data/models',
    './data/repositories',
    './domain/providers',
    './presentation/services/api_service.dart',
    './presentation/widgets',
    '.'  # to include main.dart
]

output_filename = 'all_dart_code_combined.txt'

collect_dart_files(source_directories, output_filename)
print(f"✅ All Dart files have been combined into: {output_filename}")
