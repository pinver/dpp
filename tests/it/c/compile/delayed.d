/**
   Tests for declarations that must be done at the end when they
   haven't appeared yet (due to pointers to undeclared structs)
 */
module it.c.compile.delayed;

import it;

@Tags("delayed")
@("field of unknown struct pointer")
@safe unittest {
    shouldCompile(
        C(
            q{
                typedef struct Foo {
                    struct Bar* bar;
                } Foo;
            }
        ),
        D(
            q{
                Foo f;
                f.bar = null;
            }
        ),
    );
}

@Tags("delayed")
@("unknown struct pointer return")
@safe unittest {
    shouldCompile(
        C(
            q{
                struct Foo* fun(int);
            }
        ),
        D(
            q{
                auto f = fun(42);
                static assert(is(typeof(f) == Foo*));
            }
        ),
    );
}

@ShouldFail
@Tags("delayed")
@("unknown struct pointer param")
@safe unittest {
    shouldCompile(
        C(
            q{
                int fun(struct Foo* foo);
            }
        ),
        D(
            q{
                Foo* foo;
                int i = fun(foo);
            }
        ),
    );
}


@Tags("delayed", "issue", "issue24")
@("Old issue 24")
@safe unittest {
    shouldCompile(
        C(
            q{
                typedef struct _mailstream_low mailstream_low;
                struct mailstream_cancel* mailstream_low_get_cancel(void);
                struct _mailstream {
                    struct mailstream_cancel* idle;
                };

                struct mailstream_low_driver {
                    void (*mailstream_cancel)(int);
                    struct mailstream_cancel* (*mailstream_get_cancel)(mailstream_low*);
                };

                int mailstream_low_wait_idle(struct mailstream_cancel*);

                struct _mailstream_low {
                    void* data;
                    struct mailstream_low_driver* driver;
                    int privacy;
                    char* identifier;
                    unsigned long timeout;
                    void* logger_context;
                };
            }
        ),
        D(
            q{
            }
        ),
    );
}

@ShouldFail("Renaming must not clash")
@Tags("delayed")
@("foo and foo_ cause function foo to renamed as foo__")
@safe unittest {
    shouldCompile(
        C(
            q{
                void foo(void);
                // Struct causes the function to be named foo_
                struct Struct { struct foo* field; };
                struct foo_ { int dummy; };
            }
        ),
        D(
            q{
                Struct s;
                static assert(is(typeof(s.field) == foo*));
                foo_ f;
                f.dummy = 42;
                foo__();
            }
        ),
    );
}
