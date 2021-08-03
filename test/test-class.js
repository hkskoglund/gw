class TestTop {
    test0 = 1;
    #test1 = 2;
}

class Test extends TestTop {
    test2 = 3;
    #test3 = 4;
}

let t = new Test()
console.log(t.test0);