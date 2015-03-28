package com.mycompany.app;

import junitparams.JUnitParamsRunner;
import junitparams.Parameters;

import org.junit.Test;
import org.junit.runner.RunWith;


@RunWith(JUnitParamsRunner.class)
public abstract class JunitParamsBaseTest {

    @Test
    @Parameters(method = "getFileNames")
    public abstract void runTestScript(String fileName) throws Exception;
    
    protected abstract Object[] getFileNames();
}
