import os
import shutil

# Define paths
base_path = './Complication.complicationset'  # Path to the complication set folder
resized_images_path = './resized_images'  # Path to the resized images folder

# Define the structure for each imageset and its corresponding images
imageset_structure = {
    "Graphic Extra Large.imageset": ["206.png", "264.png", "240.png"],
    "Graphic Bezel.imageset": ["94.png", "84.png"],
    "Modular.imageset": ["64.png", "58.png", "52.png"],
    "Circular.imageset": ["36.png", "32.png", "40.png"],
    "Utilitarian.imageset": ["40.png", "44.png", "50.png"],
    "Graphic Circular.imageset": ["94.png", "84.png"],
    "Extra Large.imageset": ["203.png", "182.png", "224.png"],
    "Graphic Large Rectangular.imageset": ["wide_342x108.png", "wide_300x94 copy.png"],
    "Graphic Corner.imageset": ["40.png", "44.png"]
}

# Function to copy the images based on the given structure
def copy_images(imageset_path, images_to_copy):
    for image_file in images_to_copy:
        src_image_path = os.path.join(resized_images_path, image_file)
        if os.path.exists(src_image_path):
            dest_image_path = os.path.join(imageset_path, image_file)
            shutil.copy(src_image_path, dest_image_path)
            print(f"Copied {image_file} to {imageset_path}")
        else:
            print(f"Image {image_file} not found in resized_images folder")

# Function to process the tree structure and copy the images
def process_imagesets():
    # Iterate through each subfolder in the base_path (Complication.complicationset)
    for imageset_name, images_to_copy in imageset_structure.items():
        imageset_path = os.path.join(base_path, imageset_name)
        
        # Process only if the folder exists
        if os.path.isdir(imageset_path):
            # Copy images based on the structure
            copy_images(imageset_path, images_to_copy)

if __name__ == '__main__':
    process_imagesets()
    print("Image files have been copied successfully.")
