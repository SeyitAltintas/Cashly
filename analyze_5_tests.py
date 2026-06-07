import json
import os

folder = r'C:\Users\seyit\Desktop\MobilProje\cashly\devtoolshatalari'
files = [
    '1_startup_test.json',
    '2_scroll_test.json',
    '3_navigation_test.json',
    '4_save_test.json',
    '5_chart_test.json'
]

for filename in files:
    path = os.path.join(folder, filename)
    if not os.path.exists(path):
        print(f"{filename} not found.")
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    perf = data.get('performance', {})
    frames = perf.get('flutterFrames', [])
    slow = sorted([f for f in frames if f.get('build',0) + f.get('raster',0) > 16000], key=lambda x: x.get('build',0)+x.get('raster',0), reverse=True)
    
    print(f"\n{'='*40}")
    print(f"File: {filename}")
    print(f"Total frames: {len(frames)}")
    print(f"Slow frames (>16ms): {len(slow)}")
    
    if slow:
        print("Top 5 Slowest Frames:")
        for idx, f in enumerate(slow[:5]):
            b = f.get('build',0)/1000.0
            r = f.get('raster',0)/1000.0
            print(f"  {idx+1}. UI {b:.2f}ms, Raster {r:.2f}ms")
