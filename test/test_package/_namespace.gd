# Auto-generated namespace file. Do not edit manually!
class_name NS_TestPackage extends NAMESPACE

const TestItem2 = preload("test_item2.gd")

class SubPackage:
    const CustomScene = preload("sub_package/custom_scene.tscn")
    const TestItem = preload("sub_package/test_item.gd")
    const TestItem2 = preload("sub_package/test_item2.gd")
    const TestItem3 = preload("sub_package/test_item3.gd")

    class SubsubPackage:
        const CustomScene = preload("sub_package/subsub_package/custom_scene.tscn")
        const TestItem = preload("sub_package/subsub_package/test_item.gd")

        class SubsubPackage:
            const CustomScene = preload("sub_package/subsub_package/subsub_package/custom_scene.tscn")
            const TestItem = preload("sub_package/subsub_package/subsub_package/test_item.gd")