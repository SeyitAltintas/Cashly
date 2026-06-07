import json
from typing import Dict, Any, List

def main() -> None:
    path = r'C:\Users\seyit\Desktop\MobilProje\cashly\devtoolshatalari\dart_devtools_2026-06-07_22_50_50.959.json'
    with open(path, 'r', encoding='utf-8') as json_file:
        data: Dict[str, Any] = json.load(json_file)

    perf: Dict[str, Any] = data.get('performance', {})
    frames: List[Dict[str, Any]] = perf.get('flutterFrames', [])
    slow: List[Dict[str, Any]] = sorted([frame for frame in frames if frame.get('build', 0) + frame.get('raster', 0) > 16000], key=lambda x: x.get('build', 0) + x.get('raster', 0), reverse=True)

    print(f'Total frames: {len(frames)}')
    print(f'Slow frames (>16ms): {len(slow)}')
    print('\nTop 10 Slow Frames in this new file:')
    for frame in slow[:10]:
        b = frame.get('build', 0) / 1000.0
        r = frame.get('raster', 0) / 1000.0
        print('Frame ' + str(frame.get('id')) + ': UI ' + str(round(b, 2)) + 'ms, Raster ' + str(round(r, 2)) + 'ms')

if __name__ == "__main__":
    main()
