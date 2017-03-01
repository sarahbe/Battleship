import Foundation

class Array2D<T> {
    //Define class properties
    let columns: Int
    let rows: Int
    
    //<T> store any data type(generic type)
    //Create array to hold values
    var array: Array<T?>
    
    //class constructer
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        //define array
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    //property
    subscript(column: Int, row: Int) -> T? {
        get
        {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}