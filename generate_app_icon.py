import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_app_icon(output_path="assets/icon/app_icon_1024.png"):
    size = 1024
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Base image - Deep midnight space ocean gradient
    img = Image.new("RGB", (size, size), (10, 15, 29))
    draw = ImageDraw.Draw(img)
    
    # Radial/diagonal background gradient
    for y in range(size):
        for x in range(size):
            dist = math.sqrt((x - size * 0.3)**2 + (y - size * 0.3)**2) / size
            r = int(10 + (1 - dist) * 12)
            g = int(18 + (1 - dist) * 35)
            b = int(38 + (1 - dist) * 75)
            img.putpixel((x, y), (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b))))
            
    # Draw glowing subtle background grid/concentric focus rings
    cx, cy = size // 2, size // 2
    glow_overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_overlay)
    
    # Outer Focus Progress Arc
    ring_radius = 380
    ring_width = 36
    
    # Background ring track
    glow_draw.ellipse(
        [cx - ring_radius, cy - ring_radius, cx + ring_radius, cy + ring_radius],
        outline=(0, 229, 255, 45),
        width=ring_width
    )
    
    # Progress Arc (270 degrees sweep)
    glow_draw.arc(
        [cx - ring_radius, cy - ring_radius, cx + ring_radius, cy + ring_radius],
        start=-90,
        end=190,
        fill=(0, 229, 255, 235),
        width=ring_width
    )
    
    # Endcap dot for progress
    angle_rad = math.radians(190)
    dot_x = cx + ring_radius * math.cos(angle_rad)
    dot_y = cy + ring_radius * math.sin(angle_rad)
    glow_draw.ellipse(
        [dot_x - ring_width//2, dot_y - ring_width//2, dot_x + ring_width//2, dot_y + ring_width//2],
        fill=(255, 255, 255, 255)
    )

    # Center Water Droplet Shape
    # Parametric droplet curve
    droplet_points = []
    scale = 220
    offset_y = 35 # slightly shift center
    
    for deg in range(0, 360, 2):
        rad = math.radians(deg)
        # Droplet formula: r = 1 - sin(t)
        # modified for elegant teardrop:
        x = scale * math.cos(rad) * (1.0 - math.sin(rad) * 0.45)
        y = -scale * (math.sin(rad) - math.cos(rad)**2 * 0.25) * 1.35
        droplet_points.append((cx + x, cy + y + offset_y))

    # Inner droplet glow
    glow_draw.polygon(droplet_points, fill=(0, 180, 240, 200))
    
    # Add glossy core highlight
    highlight_points = []
    for deg in range(120, 240, 4):
        rad = math.radians(deg)
        x = (scale * 0.7) * math.cos(rad) * (1.0 - math.sin(rad) * 0.4)
        y = -(scale * 0.7) * (math.sin(rad) - math.cos(rad)**2 * 0.25) * 1.35
        highlight_points.append((cx + x - 15, cy + y + offset_y - 10))
        
    if len(highlight_points) > 2:
        glow_draw.line(highlight_points, fill=(255, 255, 255, 160), width=18)

    # Soft diffuse glow
    blurred_glow = glow_overlay.filter(ImageFilter.GaussianBlur(16))
    img.paste(blurred_glow, (0, 0), blurred_glow)
    img.paste(glow_overlay, (0, 0), glow_overlay)
    
    # Ensure standard RGB without alpha channel (Mandatory for App Store)
    final_img = img.convert("RGB")
    final_img.save(output_path, "PNG")
    print(f"Master App Icon generated at {output_path}")
    return final_img

def populate_ios_icons(master_img):
    ios_icon_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    sizes = [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]
    
    for filename, sz in sizes:
        target_path = os.path.join(ios_icon_dir, filename)
        resized = master_img.resize((sz, sz), Image.Resampling.LANCZOS)
        resized.save(target_path, "PNG")
        print(f"Generated {target_path}")

if __name__ == "__main__":
    master = create_app_icon()
    populate_ios_icons(master)
