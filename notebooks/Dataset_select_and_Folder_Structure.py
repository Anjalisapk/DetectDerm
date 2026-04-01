import os, shutil, pandas as pd
from sklearn.model_selection import train_test_split

# Metadata load
df = pd.read_csv('E:/DetectDerm/HAM10000_metadata.csv')

# 4 classes filter
selected = {
    'mel':   'melanoma',
    'akiec': 'keratosis',
    'nv':    'nevus',
    'bkl':   'benign'
}
df = df[df['dx'].isin(selected.keys())]
df['label'] = df['dx'].map(selected)

# Image path find
img_dir1 = 'E:/DetectDerm/HAM10000_images_part_1/'
img_dir2 = 'E:/DetectDerm/HAM10000_images_part_2/'

def find_image(image_id):
    for folder in [img_dir1, img_dir2]:
        path = os.path.join(folder, image_id + '.jpg')
        if os.path.exists(path):
            return path
    return None

df['filepath'] = df['image_id'].apply(find_image)
df = df.dropna(subset=['filepath'])

# 80/20 split
train_df, test_df = train_test_split(
    df, test_size=0.2, random_state=42, stratify=df['label']
)

# Create folder and copy the image
for split_name, split_df in [('train', train_df), ('test', test_df)]:
    for _, row in split_df.iterrows():
        dest = os.path.join('E:/DetectDerm/dataset', split_name, row['label'])
        os.makedirs(dest, exist_ok=True)
        shutil.copy(row['filepath'], dest)

print(" Dataset ready!")
print(f"Train: {len(train_df)} | Test: {len(test_df)}")

# Verify
for split in ['train', 'test']:
    for cls in ['melanoma', 'keratosis', 'nevus', 'benign']:
        path = f'E:/DetectDerm/dataset/{split}/{cls}'
        count = len(os.listdir(path))
        print(f"{split}/{cls}: {count} images")

