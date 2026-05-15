import json
import numpy as np

# توليد مصفوفة أصفار بالأبعاد اللي الموديل مستنيها بالظبط (30, 246)
dummy_matrix = np.zeros((30, 246)).tolist()

payload = {"sequence": dummy_matrix}

# حفظها في ملف عشان تاخديها بسهولة
with open("test_data.json", "w") as f:
    json.dump(payload, f)

print("تم إنشاء الملف بنجاح! افتحي ملف test_data.json وانسخي اللي جواه.")