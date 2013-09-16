(?:abstract|final) doesn't work although it is an extended POSIX regex
Two folders are taken into consideration in our example:

tags generation for:

    abstract|final             class         (class alone auto generated)
      public|private|protected function
             private|protected $_variable...
                         const CONSTANT...
                               interface
