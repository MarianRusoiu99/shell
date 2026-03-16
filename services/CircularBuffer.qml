import QtQuick

QtObject {
    property int capacity: 0
    property var _data: []

    readonly property int count: _data.length
    readonly property var values: _data
    readonly property real maximum: {
        if (_data.length === 0)
            return 0;

        let maxVal = _data[0];
        for (let i = 1; i < _data.length; ++i)
            maxVal = Math.max(maxVal, _data[i]);
        return maxVal;
    }

    function push(value: real): void {
        if (capacity <= 0)
            return;

        const next = _data.slice();
        next.push(value);
        if (next.length > capacity)
            next.splice(0, next.length - capacity);
        _data = next;
    }

    function clear(): void {
        if (_data.length === 0)
            return;
        _data = [];
    }

    function at(index: int): real {
        if (index < 0 || index >= _data.length)
            return 0;
        return _data[index];
    }
}
