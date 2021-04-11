using System;

namespace DumbPrograms.ChromeDevTools.Generator
{
    abstract partial class CodeGenerator
    {
        internal class BlockStructureWriter : IDisposable
        {
            private readonly CodeGenerator Generator;
            private readonly BlockType BlockType;

            public BlockStructureWriter(CodeGenerator generator, string header, BlockType blockType)
            {
                Generator = generator;
                BlockType = blockType;

                if (header != null)
                {
                    generator.WIL(header);
                }

                generator.WILOpen(blockType);
            }

            public void Dispose()
            {
                Generator.WILClose(BlockType);
            }
        }
    }
}
