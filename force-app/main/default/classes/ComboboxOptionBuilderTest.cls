/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class ComboboxOptionBuilderTest {
    @IsTest
    static void testBehavior() {
        List<String> inputs = new List<String>{'Piece', 'Box', 'Each', 'ICV', 'CV'};
        ComboboxOptionBuilder.buildOptions(inputs);
    }
}