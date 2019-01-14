module it.cpp.opaque;


import it;


@("field")
@safe unittest {
    shouldCompile(
        Cpp(
            q{
                namespace myns {
                    template<typename T>
                    struct vector {
                        T* elements;
                        long size;
                    };
                }

                struct Problem {
                    long length();
                private:
                    myns::vector<double> values;
                };

                Problem createProblem();
            }
        ),
        D(
            q{
                // this should have been ignored
                static assert(!is(vector!double));
                static assert(Problem.sizeof == 16);
                auto problem = Problem();
                long l = problem.length();
            }
        ),
        ["--ignore-ns", "myns"],
   );
}


@ShouldFail
@("base")
@safe unittest {
    shouldCompile(
        Cpp(
            q{
                namespace myns {
                    struct Base{};
                }

                struct Derived: public myns::Base {

                };
            }
        ),
        D(
            q{
                auto derived = Derived();
            }
        ),
        ["--ignore-ns", "myns"],
   );
}


@("parameter.ref.const")
@safe unittest {

    with(immutable IncludeSandbox()) {
        writeFile("hdr.hpp",
                  q{
                      namespace myns {
                          struct Forbidden{};
                      }

                      struct Foo {
                          void fun(const myns::Forbidden&);
                      };
                  });
        writeFile("app.dpp",
                  `
                      #include "hdr.hpp"
                      struct Forbidden;
                      void main() {
                      }
                  `);
        runPreprocessOnly(["--ignore-ns", "myns", "app.dpp"]);
        shouldCompile("app.d");
    }
}


@("parameter.value")
@safe unittest {
    shouldCompile(
        Cpp(
            q{
                namespace myns {
                    struct Forbidden{
                        int i;
                    };
                }

                struct Foo {
                    void fun(myns::Forbidden);
                };
            }
        ),
        D(
            q{
                void[4] forbidden = void;
                auto foo = Foo();
                foo.fun(forbidden);
            }
        ),
        ["--ignore-ns", "myns"],
   );
}



@("return.ref.const")
@safe unittest {

    with(immutable IncludeSandbox()) {
        writeFile("hdr.hpp",
                  q{
                      namespace myns {
                          struct Forbidden{};
                      }

                      struct Foo {
                          const myns::Forbidden& fun();
                      };
                  });
        writeFile("app.dpp",
                  `
                      #include "hdr.hpp"
                      struct Forbidden;
                      void main() {
                      }
                  `);
        runPreprocessOnly(["--ignore-ns", "myns", "app.dpp"]);
        shouldCompile("app.d");
    }
}


@("return.value")
@safe unittest {
    shouldCompile(
        Cpp(
            q{
                namespace myns {
                    struct Forbidden{
                        int i;
                    };
                }

                struct Foo {
                    myns::Forbidden fun();
                };
            }
        ),
        D(
            q{
                auto foo = Foo();
                auto blob = foo.fun();
                static assert(is(typeof(blob) == void[4]));
            }
        ),
        ["--ignore-ns", "myns"],
   );
}


@("parameter.vector")
@safe unittest {

    with(immutable IncludeSandbox()) {
        writeFile("hdr.hpp",
                  q{
                      namespace oops {
                          template<typename T>
                              struct vector {};
                      }

                      namespace myns {
                          struct Foo {};
                      }

                      // make sure the paremeter gets translated correctly
                      void fun(oops::vector<myns::Foo>&);
                  });
        writeFile("app.dpp",
                  `
                      #include "hdr.hpp"
                      struct vector(T);
                      void main() {
                      }
                  `);
        runPreprocessOnly(["--ignore-ns", "oops", "app.dpp"]);
        shouldCompile("app.d");
    }
}


@("parameter.exception_ptr")
@safe unittest {

    with(immutable IncludeSandbox()) {
        writeFile("hdr.hpp",
                  q{
                      namespace oops {
                          namespace le_exception_ptr {
                              class exception_ptr;
                          }
                          using le_exception_ptr::exception_ptr;
                      }

                      // make sure the paremeter gets translated correctly
                      // It's referred to as oops::exception_ptr and that's what
                      // libclang will see, but its real name is
                      // oops::le_exception_ptr::exception_ptr
                      void fun(const oops::exception_ptr&);
                  });
        writeFile("app.dpp",
                  `
                      #include "hdr.hpp"
                      struct exception_ptr;
                      void main() {
                      }
                  `);
        runPreprocessOnly(["--ignore-ns", "oops", "app.dpp"]);
        shouldCompile("app.d");
    }
}
