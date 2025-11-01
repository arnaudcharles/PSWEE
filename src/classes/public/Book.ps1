class Book {
    # Class properties
    [string]   $Title
    [string]   $Author
    [string]   $Synopsis
    [string]   $Publisher
    [datetime] $PublishDate
    [int]      $PageCount
    [string[]] $Tags
    # Default constructor
    Book() { $this.Init(@{}) }
    # Convenience constructor from hashtable
    Book([hashtable]$Properties) { $this.Init($Properties) }
    # Common constructor for title and author
    Book([string]$Title, [string]$Author) {
        $this.Init(@{Title = $Title; Author = $Author })
    }
    # Shared initializer method
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
    # Method to calculate reading time as 2 minutes per page
    [timespan] GetReadingTime() {
        if ($this.PageCount -le 0) {
            throw 'Unable to determine reading time from page count.'
        }
        $Minutes = $this.PageCount * 2
        return [timespan]::new(0, $Minutes, 0)
    }
    # Method to calculate how long ago a book was published
    [timespan] GetPublishedAge() {
        if (
            $null -eq $this.PublishDate -or
            $this.PublishDate -eq [datetime]::MinValue
        ) { throw 'PublishDate not defined' }

        return (Get-Date) - $this.PublishDate
    }
    # Method to return a string representation of the book
    [string] ToString() {
        return "$($this.Title) by $($this.Author) ($($this.PublishDate.Year))"
    }
}

class BookList {
    # Static property to hold the list of books
    static [System.Collections.Generic.List[Book]] $Books
    # Static method to initialize the list of books. Called in the other
    # static methods to avoid needing to explicit initialize the value.
    static [void] Initialize() { [BookList]::Initialize($false) }
    static [bool] Initialize([bool]$force) {
        if ([BookList]::Books.Count -gt 0 -and -not $force) {
            return $false
        }

        [BookList]::Books = [System.Collections.Generic.List[Book]]::new()

        return $true
    }
    # Ensure a book is valid for the list.
    static [void] Validate([book]$Book) {
        $Prefix = @(
            'Book validation failed: Book must be defined with the Title,'
            'Author, and PublishDate properties, but'
        ) -join ' '
        if ($null -eq $Book) { throw "$Prefix was null" }
        if ([string]::IsNullOrEmpty($Book.Title)) {
            throw "$Prefix Title wasn't defined"
        }
        if ([string]::IsNullOrEmpty($Book.Author)) {
            throw "$Prefix Author wasn't defined"
        }
        if ([datetime]::MinValue -eq $Book.PublishDate) {
            throw "$Prefix PublishDate wasn't defined"
        }
    }
    # Static methods to manage the list of books.
    # Add a book if it's not already in the list.
    static [void] Add([Book]$Book) {
        [BookList]::Initialize()
        [BookList]::Validate($Book)
        if ([BookList]::Books.Contains($Book)) {
            throw "Book '$Book' already in list"
        }

        $FindPredicate = {
            param([Book]$b)

            $b.Title -eq $Book.Title -and
            $b.Author -eq $Book.Author -and
            $b.PublishDate -eq $Book.PublishDate
        }.GetNewClosure()
        if ([BookList]::Books.Find($FindPredicate)) {
            throw "Book '$Book' already in list"
        }

        [BookList]::Books.Add($Book)
    }
    # Clear the list of books.
    static [void] Clear() {
        [BookList]::Initialize()
        [BookList]::Books.Clear()
    }
    # Find a specific book using a filtering scriptblock.
    static [Book] Find([scriptblock]$Predicate) {
        [BookList]::Initialize()
        return [BookList]::Books.Find($Predicate)
    }
    # Find every book matching the filtering scriptblock.
    static [Book[]] FindAll([scriptblock]$Predicate) {
        [BookList]::Initialize()
        return [BookList]::Books.FindAll($Predicate)
    }
    # Remove a specific book.
    static [void] Remove([Book]$Book) {
        [BookList]::Initialize()
        [BookList]::Books.Remove($Book)
    }
    # Remove a book by property value.
    static [void] RemoveBy([string]$Property, [string]$Value) {
        [BookList]::Initialize()
        $Index = [BookList]::Books.FindIndex({
                param($b)
                $b.$Property -eq $Value
            }.GetNewClosure())
        if ($Index -ge 0) {
            [BookList]::Books.RemoveAt($Index)
        }
    }
}

enum Binding {
    Hardcover
    Paperback
    EBook
}

enum Genre {
    Mystery
    Thriller
    Romance
    ScienceFiction
    Fantasy
    Horror
}
